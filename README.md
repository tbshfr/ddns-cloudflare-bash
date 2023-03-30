# 🚀 Simple dynamic DNS update script for Cloudflare

## Access your home network through your own domain without a static IP! 

On most Linux versions, you just have to run the script; there is no need to install anything.
The script should be executed periodically by a cronjob.

If your public IP has changed since the last run, your Cloudflare A record will be updated.   
Connections to the Cloudflare API are only made if the record has to be updated.

### Features:
---
- works with Zone API Tokens; no need to use your global API key
- receive updates via Telegram notifications
- easy configuration
- fast and lightweight
- quick access to your IP history

### Quick start
---
Whole walkthrough with screenshots is coming soon!
- create an Cloudflare API token ([CF Documentation](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/))
- find your Zone ID ([CF Documentation](https://developers.cloudflare.com/fundamentals/get-started/basic-tasks/find-account-and-zone-ids/))
- create your A record on the CF Webinterface (doesn't matter where it points to)
- (Optional) create Telegram Bot; contact [Botfather](https://t.me/botfather) with /newbot and follow the instructions
- (Optional) send a message to [@userinfobot](https://t.me/userinfobot) to get your chat ID
- copy the script and edit the variables 
- make it executable with ```chmod +x dyndns.sh```
- add a cronjob with ```crontab -e``` 
  ```
  */5 * * * * /path/to/script/dyndns.sh > /dev/null 2>&1
  ```
  This cronjob will execute the script every 5 minutes.

### Privacy:
- it uses icanhazip.com to get your public IP; this service is also operated by Cloudflare ([source](https://major.io/icanhazip-com-faq))
- if you choose to use telegram notifications, the script will connect to the Telegram API
