:log warning "----------BandwidthScriptSTART----------"
:local interfaces [/interface find where name~"vpn-" and type!="ovpn-in" and running=yes]
:local lenvpnint [:len $interfaces]
:local rxdict ({})
:local txdict ({})
:local intdict ({})
:local ipdict ({})

:log warning "Total running VPN interface: $lenvpnint"

:foreach int in=$interfaces do={
:local interfaceName [:tostr [/interface get $int name]]
:local ipaddr [/ip address get [find where interface=$interfaceName] network]
:set intdict ($intdict, $interfaceName)
:set ipdict ($ipdict, $ipaddr)
:local rxAvg 0
:local txAvg 0
/tool bandwidth-test address=$ipaddr duration=10s direction=both protocol=tcp connection-count=1 user=admin password="#elpPOL!" random-data=yes do={
:set rxAvg ($"tx-total-average"/1000000)
:set txAvg ($"rx-total-average"/1000000)
}
:set rxdict ($rxdict, $rxAvg)
:set txdict ($txdict, $txAvg)
:log info message="$interfaceName-$ipaddr Rx/Tx: $rxAvg/$txAvg Mbps"
}

:log info $rxdict
:log info $txdict
:log info $intdict

:local maxrx ($rxdict->0)
:local minrx ($rxdict->0)

:foreach i in=$rxdict do={
  :if ($i > $maxrx) do={:set maxrx $i}
  :if ($i < $minrx) do={
    :set minrx $i
  }
}

:local maxtx ($txdict->0)
:local mintx ($txdict->0)

:foreach j in=$txdict do={
  :if ($j > $maxtx) do={:set maxtx $j}
  :if ($j < $mintx) do={
    :set mintx $j
  }
}

:log warning "max RX = $maxrx"
:log warning "min RX = $minrx"
:log warning "max TX = $maxtx"
:log warning "min TX = $mintx"

:local intdictsort $intdict;
:local A;
:local rxdictsort $rxdict;
:local B;
:local n [ :len $rxdictsort ];
:local swapped;
:put "Before unsorted $rxdictsort";
do {
    :set swapped false;
    :for i from=1 to=($n - 1) do={
        :if ([ :pick $rxdictsort ($i - 1) ]  > [ :pick $rxdictsort $i ]) do={
            :set B [ :pick $rxdictsort ($i - 1) ];
            :set A [ :pick $intdictsort ($i - 1) ];
            :set $rxdictsort ([ :pick $rxdictsort 0 ($i - 1) ], [ :pick $rxdictsort $i ], $B, [ :pick $rxdictsort ($i + 1) [ :len $rxdictsort ] ]);
            :set $intdictsort ([ :pick $intdictsort 0 ($i - 1) ], [ :pick $intdictsort $i ], $A, [ :pick $intdictsort ($i + 1) [ :len $intdictsort ] ]);
            :set swapped true;
        }
    }
    :set n ($n - 1);
} while=($swapped);

:log warning $rxdictsort
:log warning $intdictsort

:local ipdict2 ({})

:foreach k in=$intdictsort do={
  :local ipaddr2 [/ip address get [find where interface=$k] network]
  :set ipdict2 ($ipdict2, $ipaddr2)
}

:log warning $ipdict2

:local dist 10

:foreach m in=$iparray do={
  /ip route set [find where routing-table=VPN and gateway=$m] distance=$dist;
  /ip route set [find where routing-table=VPN and gateway=$m] disabled=no;
  :set dist ($dist + 1);
}

:log warning "----------BandwidthScriptEND----------"