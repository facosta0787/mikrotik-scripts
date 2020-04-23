# This is a basic parser, can be used for XML
# It takes three parameters:
# xml - The main string
# start - Text AFTER this point will be returned
# end - Text BEFORE this point will be returned
:local getXmlValue do={
  :local posStart 0;
  :if ([:len $start] > 0) do={
  :set posStart [:find $xml $start]
    :if ([:len $posStart] = 0) do={
      :set posStart 0
    } else={
      :set posStart ($posStart + [:len $start])
    }
  }

  :local posEnd 9999;
  :if ([:len $end] > 0) do={
  :set posEnd [:find $xml $end];
  :if ([:len $posEnd] = 0) do={ :set posEnd 9999 }
  }

  :local result [:pick $xml $posStart $posEnd];
  :return $result;
}

# Process to update DDNS on NameCheap
/tool fetch output=file dst-path=wanip.txt url="http://ipv4bot.whatismyipaddress.com/";
/delay delay-time=2;

:local publicip value=[/file get [find where name=wanip.txt] value-name=contents];

:if ([:len $publicip] != 0) do={

  :local hosts {
    {pwd=""; domain=""; host=""};
    {pwd=""; domain=""; host=""}
  };

  :local namecheapurl value="https://dynamicdns.park-your-domain.com/update";
  :local URL;
  :foreach item in=$hosts do={
    :set URL value=($namecheapurl."?password=".($item->"pwd")."&domain=".($item->"domain")."&host=".($item->"host"));

    /tool fetch output=file dst-path=nc-response.txt url=($URL."&ip=".$publicip);
    /delay delay-time=2;

    :local xmlresponse value=[/file get [find where name=nc-response.txt] value-name=contents];
    :local response value=[$getXmlValue xml=$xmlresponse start="<ErrCount>" end="</ErrCount>"];

    :if ($response = "0") do={:log warning message=("Host ".($item->"host")." on domain ".($item->"domain")." updated successfully with IP ".$publicip);};
    :if ($response != "0") do={:log error message=("Fail to update host ".($item->"host")." on domain ".($item->"domain")." with new IP ".$publicip);};

    :if ([:len [/file find name=nc-response.txt]] > 0) do={/file remove nc-response.txt};
  }
}

:if ([:len [/file find name=wanip.txt]] > 0) do={/file remove wanip.txt};
