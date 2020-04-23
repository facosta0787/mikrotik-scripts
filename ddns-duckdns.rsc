## Update public ip on DuckDNS
:global token value="";
:global domain value="";

/tool fetch output=file dst-path=wanip.txt url="http://ipv4bot.whatismyipaddress.com/";
/delay delay-time=2;

:global publicip value=[/file get [find where name=wanip.txt] value-name=contents];

:if ([:len $publicip] != 0) do={
  /tool fetch output=file dst-path=duckdns-response.txt url=("https://www.duckdns.org/update?token=".$token."&domains=".$domain."&ip=".$publicip);
  /delay delay-time=2;

  :global response value=[/file get [find where name=duckdns-response.txt] value-name=contents];

  :if ($response = "OK") do={:log warning message=("DuckDNS update successfull with IP ".$publicip);};
  :if ($response = "KO") do={:log error message=("Fail to update DuckDNS with new IP ".$publicip);};

  /delay delay-time=2;
  /file remove duckdns-response.txt;
}

/delay delay-time=2;
/file remove wanip.txt;