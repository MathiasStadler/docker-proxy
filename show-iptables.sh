#!/bin/bash

iptables -t nat  -L  -n -v --line-numbers
iptables -t mangle  -L  -n -v --line-numbers
