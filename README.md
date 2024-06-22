# PHP 5.4.45 FPM (2014), Apache/2.4.54, Exim 4.94.2, debian11.6 (bullseye)

[![Docker php 5.4.45](https://github.com/RootShell-coder/php/actions/workflows/docker-image.yml/badge.svg)](https://github.com/RootShell-coder/php/actions/workflows/docker-image.yml)

```diff
- Note: _that php 5.4.45 has reached end of life and is not being security supported further. Because unpatched systems are easy to compromise and compromised systems are often used to attack other systems, you should consider upgrading promptly to a supported version so as not to be a hazard to the Internet._
```

_dkim_

`docker exec -ti $(docker ps | grep "rootshell-coder/php:5.4.45" | awk {'print $1'}) /usr/local/dkim/gen_dkim.sh`

```bash
Publish your public key to your DNS record as a text (TXT) record.
Check with your DNS provider to see if they allow more than 255 characters in the input field or not,
as you may have to work with your provider to increase the size or to create the TXT record itself.

dkim._domainkey.example.com TXT "v=DKIM1; g=*; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4SdtYMmjINbb9++p7d3vBVqJjnSSAQEJxBFBD7K4jl82xmNgmuxkv+o80Qflq6XToktYptE/rjzZluWsjiKLQ3pAXGNoc7eEPlLSuQwO1CJpXOWjsXWYFey/2C8hhrsbKOhayHE5TMsadBnGlCdpBibd4" "AYrmRdFO/Rr/5Cxo4i0GIkx7zOpPVW/iuqcex9cxq7D93uTR0rjYbnyYmZWtKERGpu80osMq2isk6il37c2kXo3jH2ugBfHa86MB7Z4U9Ec90+LlvUb3N5NAKyzKeF2ehTp0Zy5sFtu4iihI8922OCE6ciK/3fwK70VH5H3NFt/plCabOO4pgr3zydjnwIDAQAB"

And add SPF TXT record "v=spf1 ip4:93.184.216.34 ~all"
```

_php sendmail_

```php
<?php
  error_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE);
  ini_set("display_errors", 1);

  $to       = 'webmaster@example.com';
  $subject  = 'the subject';
  $message  = 'hello';

    $headers  = "From: noreply <noreply@example.com>\n";
    $headers .= "X-Sender: noreply <noreply@example.com>\n";
    $headers .= 'X-Mailer: PHP/' . phpversion();
    $headers .= "X-Priority: 1\n";
    $headers .= "Return-Path: noreply@example.com\n";
    $headers .= "MIME-Version: 1.0\n";
    $headers .= "Content-Type: text/html; charset=iso-8859-1\n";

mail($to, $subject, $message, $headers);
?>
```
