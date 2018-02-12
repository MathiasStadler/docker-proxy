#iproute2 cheat sheet

# list all interfeces
- ```ip l
ip link show
    ```

# list all addr
- ```ip a
    ip addr show
    ```
# show all name of routing tables
- ```ip rule show```

# show content of routing table
- ```ip route show table <name>```
    e.g. 
    ```ip route show table local``` 