
If hosts on your **internal LAN** suddenly flip to *host unreachable*, you’re looking for either:

* ARP/DHCP poisoning or conflict
* A bad / stale DHCP lease (wrong gateway, wrong netmask, wrong DNS)
* A rogue DHCP server
* A host pushing bad static routes
* A flaky switch port or VLAN misconfig

Here’s how to **actively monitor** and **catch the moment it breaks** on Linux.

---

## 1. Continuous ARP + ping watch (best first step)

Run both simultaneously so you can see **whether the host disappears at L2 first or at L3**:

```bash
sudo arpwatch -i eth0
```

And a continuous reachability test:

```bash
watch -n1 "ping -c1 -W1 192.168.1.50 | grep 'ttl\|unreachable'"
```

If ARP suddenly reports flip-flopping MACs or “changed ethernet address”, you’ve found the culprit (rogue DHCP, spoofing, or a rebinding issue).

---

## 2. Log DHCP lease behavior in real time

Watch your system’s DHCP client:

**NetworkManager systems:**

```bash
sudo journalctl -u NetworkManager -f
```

**dhclient systems:**

```bash
sudo tail -f /var/log/syslog | grep dhclient
```

You’re looking for:

* Lease renews giving a *different* router
* Incorrect subnet mask
* A lease from an unexpected DHCP server

---

## 3. Detect rogue DHCP servers

Scan the LAN:

```bash
sudo nmap --script broadcast-dhcp-discover
```

It will list all DHCP servers that respond. If you see **more than one**, that’s your issue.

---

## 4. Monitor routing table for unexpected changes

Sometimes a misconfigured system advertises bad routes.

```bash
watch -n1 "ip route show"
```

Unexpected default gateway appearing/disappearing = bad DHCP or rogue router advertisement.

For IPv6 RA issues:

```bash
sudo rdisc6 eth0
```

---

## 5. Capture the moment things break (automated)

Set up a simple loop that logs the *first failure*:

```bash
#!/bin/bash
TARGET=192.168.1.50
while true; do
    if ! ping -c1 -W1 $TARGET >/dev/null; then
        echo "$(date) - unreachable" >> /var/log/host_watch.log
        ip addr >> /var/log/host_watch.log
        ip route >> /var/log/host_watch.log
        arp -n >> /var/log/host_watch.log
        sleep 5
    fi
    sleep 1
done
```

This grabs the **network state at the exact moment** the host becomes unreachable.

---

## 6. If you suspect a bad DHCP option (bad router, DNS, static route)

Dump full DHCP info:

```bash
sudo dhclient -v -r && sudo dhclient -v
```

Look for:

* `option routers` (should be your LAN gateway)
* `option subnet-mask`
* `option domain-name-servers`
* `option static-routes` (rare but deadly if misconfigured)

---

If you tell me:

* The subnet layout
* The DHCP server you use
* Whether the issue hits one host or many
* Whether it starts after lease renewal

I can pinpoint the cause quickly.

Got it — **wired, server-to-server**, brief unreachable, then everything comes back.
On pure wired infrastructure between servers, the set of real causes shrinks dramatically.
Here’s the brutally honest list of what actually causes this pattern in enterprise networks.

---

# ✔ 1. DHCP renewal interrupting routing (the #1 cause on Linux servers)

Even on wired server links, some distros momentarily:

* Drop default route
* Flush ARP
* Rebind the address
* Reinstall routes

This creates a sub-second or multi-second outage.
If multiple servers renew at the same time → cluster or service blips.

### How to verify

```
journalctl -f | grep -i dhcp
```

Look for:

* `renew`
* `bound`
* `trying next server`
* `removing default route`

And run:

```
watch -n0.2 "ip route show"
```

If the default route disappears → case closed.

---

# ✔ 2. ARP table churn during lease renew

Linux will ARP-probe for conflicts when renewing a lease.

If:

* The ARP probe gets delayed
* A switch is under load
* A port briefly flaps
  …you get a moment of **“host unreachable”** because ARP resolution fails.

### Check

```
ip monitor neigh
```

If you see REACHABLE → STALE → FAILED right at the outage timestamp, that’s it.

---

# ✔ 3. Redundant DHCP servers responding inconsistently

On enterprise networks:

* Infoblox HA pairs
* Windows DHCP failover
* Cisco DHCP relay mismatches

These sometimes return **different gateway or mask settings** depending on which node responds.

Linux then momentarily thinks:

* “My gateway changed”
* Removes old route
* Adds new one

→ Micro-outage.

Scan with:

```
nmap --script broadcast-dhcp-discover
```

If more than one server answers, you have a failover flapping problem.

---

# ✔ 4. Switchport features causing micro-interruptions

Even on steady wired links, these features can create *very* brief network loss:

### a) DHCP Snooping rate-limits

If a server renews too aggressively or multiple servers renew at once, snooping briefly cuts ARP or DHCP traffic.

### b) STP transitions (PortFast missing)

If the port ever hits a transition due to a topology event elsewhere, you get a tiny interruption.

### c) LACP rebalancing on bonded NICs

If you’re using a bond (LACP mode 4), renewals sometimes coincide with link renegotiation.

Check logs:

```
dmesg | grep -E "bond|link|carrier"
```

---

# ✔ 5. Duplicate IP or MAC event during lease renewal

Rare, but lethal for a few seconds.

Linux sends:

* ARP “who-has”
* ARP “gratuitous ARP”

If another host responds incorrectly or a VM bridge forwards something weird, the kernel marks the IP as duplicated → temporarily unusable.

Check:

```
dmesg | grep -i duplicate
```

---

# ✔ What to do next — quick actionable diagnostics

To nail this down definitively, run these **three monitors in parallel** on one affected server:

### 1. DHCP + routing monitor

```
sudo journalctl -f | egrep "dhcp|dhclient|renew|bound"
```

### 2. ARP + route watcher

```
watch -n0.2 "ip route; echo; ip neigh"
```

### 3. Detect interface / link blips

```
dmesg -w | grep -i "link"
```

If you run all three, the root cause will show itself immediately.

---

# ✔ If you want, tell me

* Distro/version (RHEL, Debian, Ubuntu, SUSE, etc.)
* NIC bonding or single-NIC?
* Switch vendor (Cisco, Aruba, Juniper, etc.)
* DHCP server type
* Lease duration

With that, I can tell you *exactly* which failure mode you’re hitting and how to fix it permanently.

If you're suspecting **SSSD** as the reason hosts go briefly unreachable (it *can* indirectly cause symptoms that look like network hiccups), here’s how to check it properly.

Straight, practical, no-nonsense checklist:

---

# ✔ 1. Check SSSD logs directly (most important)

SSSD logs everything it’s struggling with, especially timeouts.

Look here:

```
/var/log/sssd/sssd.log
/var/log/sssd/sssd_domain.log
/var/log/sssd/sssd_nss.log
/var/log/sssd/sssd_pam.log
```

Tail them live:

```
sudo tail -f /var/log/sssd/*.log
```

What you’re looking for:

* `Timed out`
* `Backend is offline`
* `Unable to resolve`
* `krb5_child timed out`
* `dp_req_recv: Invalid argument`
* `resolving server failed`

If you see timeouts around the moment your hosts “go unreachable” → SSSD is stalling system calls.

---

# ✔ 2. Look for SSSD blocking NSS/PAM (common and ugly)

If SSSD hangs, **NSS** (name lookup) hangs, and processes waiting on DNS/ID lookup freeze — this can *look like* network stalls.

Test lookup time:

```
time getent passwd some_user
time getent group some_group
```

If these take >1 second → SSSD is choking.

---

# ✔ 3. Check whether SSSD is going “offline/online”

Run:

```
sssctl domain-list
sssctl domain-status <yourdomain>
```

Red flags:

* `online: no`
* `cache_expired: yes`
* `offline` events repeating

SSSD going offline triggers timeout cascades across the system, often mistaken for network glitches.

---

# ✔ 4. See if SSSD is killing DNS resolution

SSSD hooks into NSS — if it can’t talk to the AD/DC/IdP, it drags down lookups.

Check normal DNS resolve speed:

```
time dig yourdomain.com
time dig _ldap._tcp.yourdomain.com SRV
```

If DNS is fine but `getent` is slow → SSSD is at fault.

---

# ✔ 5. Check systemd watchdog status

SSSD often leaves traces:

```
systemctl status sssd
journalctl -u sssd -f
```

Look for:

* `Watchdog timeout`
* `Service restarted`
* `I/O warning`
* `Backend timed out`

---

# ✔ 6. Check LDAP/Kerberos reachability (SSSD backend)

SSSD depends on these staying rock solid:

```
ldapsearch -x -H ldap://your_ldap_server -b "" -s base
kinit your_user
```

If these commands hesitate at the same time your servers “go unreachable,” SSSD is likely choking due to backend flakiness.

---

# ✔ 7. Temporarily bypass SSSD to confirm it's the culprit

This is the fastest way to prove SSSD is causing stalls.

**Test 1 — bypass user lookups**
Edit `/etc/nsswitch.conf` and temporarily change:

```
passwd:     files systemd sss
group:      files systemd sss
```

to:

```
passwd:     files systemd
group:      files systemd
```

If the micro-outages disappear → SSSD is the root cause.

**Test 2 — stop SSSD**

```
sudo systemctl stop sssd
```

If the freezes/unreachable moments stop → confirmed.

(Obviously don’t leave it off in production; this is diagnostic.)

---

# ✔ 8. Check SSSD cache corruption (rare but real)

```
sssctl cache-status
```

If you see corruption indicators, clear the cache:

```
sudo sss_cache -E
sudo systemctl restart sssd
```

---

# ✔ Summary of clear indicators SSSD is the problem

You’ll know it’s SSSD if:

* `getent passwd` hangs or is slow
* SSSD logs show backend timeouts
* Domain status shows offline/online flapping
* Stopping SSSD instantly stabilizes the system
* DNS queries are fast but ID lookups are slow
* Kerberos/LDAP failures appear around outage time

SSSD doesn’t break routing, but it **blocks NSS**, causing processes to freeze and making the system look dead/unreachable for a short time.

---

If you want, tell me:

* The OS (RHEL 7/8/9? Ubuntu? SLES?)
* Whether you use AD, FreeIPA, or LDAP
* Whether your servers use SSSD for sudo rules, HBAC, or ID lookup
* Exact moment logs from sssd.log around an outage

I can pinpoint the failure pattern exactly.
