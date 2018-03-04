# netcat

## create request file

```bash
GET / HTTP/1.1
Host: superuser.com
User-Agent: Mozilla/5.0
```

## use nc for request web site

```bash
nc superuser.com 80 <req >res
```