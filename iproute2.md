##iproute2 cheat sheet

# list all interfeces
```bash
ip l
ip link show
```

# list all addr

```bash
ip a
ip addr show
```

# show all name of routing tables

```bash
ip rule show
```

# show content of routing table

```bash
ip route show table <name>
```

- e.g.

```bash
ip route show table local
```