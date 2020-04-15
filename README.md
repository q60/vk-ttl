# VK TTL

Script, that allows you to send TTL (temporary) messages in VK, written in R

If you want to use this script, you should firstly install **R lang** on your system and then install **httr** library from *CRAN*.

```R
install.packages("httr")
```

Then you must add your **[VK Me token](https://oauth.vk.com/authorize?client_id=6146827&redirect_uri=https://oauth.vk.com/blank.html&display=page&response_type=token&revoke=1&scope=messages)** to the script in the first variable named *api_token*.

Then just launch the script using terminal
```sh
Rscript ttl.R
```

Shebang in the beginning of the code allows you to make it executable without need of launching it with `Rscript`.
```sh
chmod +x ttl.R
./ttl.R
```
