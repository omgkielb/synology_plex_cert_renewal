#!/bin/sh

#### Inputs ####
# File Name and Path for naming file and cert conversion #
# File needs to be added to Plex under Settings -> Network -> Custom certificate location #
# Ensure you also update the Custom certificate domain and Custom server access URLs on the same plage #
plex_cert_path=PATH_TO_PFX_FILE
domain_name=NAME_OF_FILE

# p12 password - Replace password with your own #
# Password needs to be added to Plex under Settings -> Network -> Custom certificate encryption key #
p12cert_password=REPLACE_PASSWORD

# p12 file #
p12_file_path="$plex_cert_path/$domain_name.pfx"

### Below values can remain the same ###
# Synology's Default Let's encrypt folder #
letsencrypt_cert_folder=/usr/syno/etc/certificate/system/default

## There will be both RSA/ECC if using letsencrypt ##
# If unsure of your certs just uncomment the below, enable task to via email to see outputs.
# ls -al $letsencrypt_cert_folder
cert_prefix="ECC-"

### Used in below scripts ###
current_date=$(date +"%s")
current_certificate_date=$(openssl x509 -enddate -noout -in "$letsencrypt_cert_folder/${cert_prefix}cert.pem" | cut -d'=' -f2)
current_certificate_timestamp=$(date -d "$current_certificate_date" +"%s")

# check if it is necessary to renew the certificate or not
if [[ ! -f "$p12_file_path" ]] || (( current_date > current_certificate_timestamp )); then
  # generate a new p12 file
  echo "Generating the p12 certificate file."
  rm -f "$p12_file_path"
  openssl-3 pkcs12 -export -out "$p12_file_path" \
    -in "$letsencrypt_cert_folder/${cert_prefix}cert.pem" \
    -inkey "$letsencrypt_cert_folder/${cert_prefix}privkey.pem" \
    -certfile "$letsencrypt_cert_folder/${cert_prefix}fullchain.pem" \
    -name "$domain_name" \
    -password "pass:$p12cert_password" \
    -certpbe AES-256-CBC -keypbe AES-256-CBC -macalg SHA256
  chmod +r "$p12_file_path"
  chown admin:users "$p12_file_path"
  echo "Restarting Plex Media Server."
  echo "Plex Certificate will expire on the ${current_certificate_date}."
  /bin/systemctl restart pkgctl-PlexMediaServer
  echo "Done."
else
  echo "Plex Certificate does not need to be replaced."
  echo "Expiry date is ${current_certificate_date}."
fi
