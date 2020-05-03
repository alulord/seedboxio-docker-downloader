# Docker Downloader for seedbox.io

This docker set up allows you to set up a local dockerized Sonarr, Radarr, Jackett, and Resilio Sync, that will automatically hook up to your seedbox.io seedbox instance, straight out of the box. It even has an nginx reverse proxy sitting on port 80 to give you a front page to your media services.

### Caveat:

**Warning:** This whole README uses the same hostname, psv23232.seedbox.io. Anywhere you see that, change it to your seedbox.io hostname.


# Installation

Set your seedbox.io name as an environment variable.

```
export SEEDHOST=psv23232.seedbox.io
open https://$SEEDHOST/dav
```

* Create a directory called `CompletedDownloads`


```
open https://$SEEDHOST
```

* Click on the settings icon. Go to "Autotools". Make sure AutoMove is checked, if torrent's label matches filter /.*/ with the directory, /home/psv23232/files/CompletedDownloads. Also check the "Add torrent's label to path"
![rTorrent Settings](https://github.com/hjhart/docker-downloader/blob/master/assets/rtorrent_settings.png)

Now go add the `CompletedDownloads` directory.

```
open https://$SEEDHOST/resilio
```

* Add that directory in Resilio Sync, copy the read-only secret.

```
cp .env.example .env
```

Now edit the .env file to include your newly generated Resilio Sync secret as RSLSYNC_SECRET.

While you're in the .env file, add in correct data for MOVIE_DIR, TV_SHOW_DIR, and STORAGE_DIR. These represent where you want you movies, your tv shows, and where your completed downloads should go.

## Creating ssl certificates

To use on traefik you have to generate certificates in `traefik/certs` directory

### Self sign cert

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout seedbox.key -out seedbox.crt
```

### CA with cert

Generate your ca key and cert
```bash
cd traefik/ssl
touch serial .rnd index.txt
echo 01 > serial
openssl genrsa -des3 -out private/rootCA.key 4096 
openssl req -x509 -new -nodes -key private/rootCA.key -sha256 -days 1024 -out rootCA.crt -config openssl.cnf -extensions v3_ca
```

create key and request for your server

```bash
openssl genrsa -out private/seedbox.key 2048 
openssl req -new -key private/seedbox.key -out csr/seedbox.csr -config openssl.cnf -extensions v3_req 
```

sign the request with your ca

```bash
openssl ca -config openssl.cnf -extfile seedbox.extension.cnf -in csr/seedbox.csr -out newcerts/seedbox.crt
```

## Configure Radarr:

* Add indexers that you want to add. (Jackett can be configured / found on port 9117)
* Add rTorrent as a Download Client to point to your seedbox.io. [See this article](https://panel.seedbox.io/index.php?rp=/knowledgebase/41/How-to-connect-Sonarr-to-your-service.html)
* Toggle "Advanced Settings" in the Download Client tab.
* Add a new Remote Path Mapping like this:

```
   host                               remote path                                        local path
psv23232.seedbox.io       /home/psv23232/files/CompletedDownloads/radarr/              /downloads/radarr/

```

## Configure Sonarr: 

* Add indexers that you want to add. (Jackett can be configured / found on port 9117)
* Add rTorrent as a Download Client to point to your seedbox.io. [See this article](https://panel.seedbox.io/index.php?rp=/knowledgebase/41/How-to-connect-Sonarr-to-your-service.html)
* Add a new Remote Path Mapping like this:

```
   host                               remote path                                        local path
psv23232.seedbox.io       /home/psv23232/files/CompletedDownloads/sonarr/              /downloads/sonarr/

```

# Monitoring

There are configs for [M/Monit](https://mmonit.com/monit/documentation/monit.html) system monitoring. Symlink them to monit config folder and reload.

## Notifications

Notifications are done via [PushBullet](https://www.pushbullet.com). To use it as cli, you have to install python pip package [pushbullet-cli](https://pypi.org/project/pushbullet-cli/) and setup `PUSHBULLET_KEY` environment variable in `/etc/environment` with your access key.

# Congratulations!

Now you should be all set up. If you have any problems, leave an issue in github and I'll get back to you.


TODO:


* Figure out how to configure Download Clients automatically and check it into version control
* (Essentially figure out how to remove the "Configure Radarr / Sonarr" manual steps)
* Add download clients automatically
