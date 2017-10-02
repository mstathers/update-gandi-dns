# update-gandi-dns - a simple perl script to update gandi DNS records

This is a little Perl script I created using the
<a href="http://doc.rpc.gandi.net/domain/" target="_blank">Gandi API</a>
to update the DNS record of a hostname.

# Installation

1) Copy the included script, update_gandi_dns.pl, to the location where
   you want.

2) Place the "gandi_api_key" file in the same directory.

3) Edit the "gandi_api_key" and replace the contents with your 24
   digit Gandi API key.

# Usage

```
./update_gandi_dns.pl <-h hostname> <-d domain> <-i ipv4_address>
```

# Author

The original author was Michael Stathers. For more information, consider
contacting him at:

* Website -> www.stathers.net

Some adjustments by Robert Bisewski at Ibis Cybernetics. For more
information, contact:

* Website -> www.ibiscybernetics.com

* Email -> contact@ibiscybernetics.com
