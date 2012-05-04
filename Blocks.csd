<CsoundSynthesizer>
<CsOptions>
-odac -d -+msg_color=false
</CsOptions>
<CsInstruments>

ksmps = 64
gituio TUIOinit 3333

; Time to hold all symbols to compensate for false turnoffs.
gkhold init 0.5


gisemitones ftgen 0, 0,8,-2, 0,2,4,5,7,9,11,0

gisubdiv ftgen 0,0,8,-2,0.25,0.5,1, 2, 3,4

isymindex = 0
iparamindex = 0
init_sym_loop:

    init_loop:
    Sname sprintf "p%i_%i", isymindex, iparamindex
    chn_k Sname, 1
    loop_lt iparamindex, 1, 50, init_loop

loop_lt isymindex, 1, 50, init_loop
; scale types
giminor ftgen 300, 0, 8, -2, 0, 2, 3, 5, 7, 8, 10, 12
gimajor ftgen 301, 0, 8, -2, 0, 2, 4, 5, 7, 9, 11, 12
gipenta ftgen 302, 0, -6, -2, 0, 2, 4, 7, 9, 12
gidblharm ftgen 303, 0, 8, -2, 0, 1, 4, 5, 7, 8, 11, 12

;arpegio chords
gimajchrd ftgen 400,0,-3,-2, 0,4,7
giminchrd ftgen 401,0,-3,-2,0,3,7
gi7chrd ftgen 402,0,-4,-2, 0,4,7,10
gim7chrd ftgen 403,0,-4,-2,0,3,7,10
gimaj7chrd ftgen 404,0,-4,-2, 0,4,7,11
gi5chrd ftgen 405,0,-2,-2, 0,7
gisus4chrd ftgen 406,0,-3,-2, 0,5,7

gisymbolon ftgen 0, 0, 32, -2, 0

giclass ftgen 0,0, 16, -2, 0,0,1,1,2,3,3,4,4,5,5,6
gialt  ftgen 0,0, 16, -2, 0,1,0,1,0,0,1,0,1,0,1,0

opcode noteToMidi, k, kkk
;; note 0-7 (diatonic), alt 0=natural, 1=sharp, 2=flat; oct C4=middle C
knote, kalt, koct xin

ksemitones table knote, gisemitones
ksemitones = ksemitones + (kalt == 1? 1 : 0) + (kalt==2? -1 : 0)

kmidi = 60 + (12 *(koct -4)) + ksemitones
xout kmidi
endop

opcode noteToMidi_i, i, iii
;; note 0-7 (diatonic), alt 0=natural, 1=sharp, 2=flat; oct C4=middle C
inote, ialt, ioct xin

isemitones table inote, gisemitones
isemitones = isemitones + (ialt == 1? 1 : 0) + (ialt==2? -1 : 0)

imidi = 60 + (12 *(ioct -4)) + isemitones
xout imidi
endop

opcode semitoneToClass, kk, k
ksemitone xin
kclass table ksemitone, giclass
kdev table ksemitone, gialt
xout kclass, kdev
endop

opcode storeParameter, 0, ii
; iindex is the index of the parameter
isymbol, iindex xin
Sname sprintf "p%i_%i", isymbol, iindex
kval chnget Sname
ktrig changed kval
if ktrig == 1 then
	tablew kval, iindex, 200 + isymbol
endif
endop 

opcode getParameter, k, ii
isymbol, iindex xin
kval table iindex, 200 + isymbol
xout kval
endop

opcode getParameter_i, i, ii
isymbol, iindex xin
ival tab_i iindex, 200 + isymbol
xout ival
endop

instr 1 ; Receive parameters
isymbol = p4
printf_i "Receive parameters for symbol %i\n", 1, isymbol
itable ftgen 200 + isymbol,0, 256, 2, 0 ; store parameters

storeParameter isymbol, 0
storeParameter isymbol, 1
storeParameter isymbol, 2
storeParameter isymbol, 3
storeParameter isymbol, 4
storeParameter isymbol, 5
storeParameter isymbol, 6
storeParameter isymbol, 7
storeParameter isymbol, 8
storeParameter isymbol, 9
storeParameter isymbol, 10
storeParameter isymbol, 11
storeParameter isymbol, 12
storeParameter isymbol, 13
storeParameter isymbol, 14
storeParameter isymbol, 15
storeParameter isymbol, 16
storeParameter isymbol, 17
storeParameter isymbol, 18
storeParameter isymbol, 19
storeParameter isymbol, 20
storeParameter isymbol, 21
storeParameter isymbol, 22
storeParameter isymbol, 23
storeParameter isymbol, 24
storeParameter isymbol, 25
storeParameter isymbol, 26
storeParameter isymbol, 27
storeParameter isymbol, 28
storeParameter isymbol, 29
storeParameter isymbol, 30
storeParameter isymbol, 31
storeParameter isymbol, 32
storeParameter isymbol, 33
storeParameter isymbol, 34
storeParameter isymbol, 35
storeParameter isymbol, 36
storeParameter isymbol, 37
storeParameter isymbol, 38
storeParameter isymbol, 39
storeParameter isymbol, 40
storeParameter isymbol, 41
storeParameter isymbol, 42
storeParameter isymbol, 43
storeParameter isymbol, 44
storeParameter isymbol, 45
storeParameter isymbol, 46
storeParameter isymbol, 47
storeParameter isymbol, 48
storeParameter isymbol, 49

endin

instr 10  ; Receive TUIO


ktrigadd, ksymbol, kxpos, kypos, kangle, ksession addObject gituio

; first unschedule any scheduled destructors
if ktrigadd == 1  && ksymbol < 12 then
	tablewkt kxpos, 100, 200 + ksymbol
	tablewkt kypos, 101, 200 + ksymbol
	tablewkt kangle, 102, 200 + ksymbol
	kinsno = 20 + (ksymbol/100)
	kactive table ksymbol, gisymbolon
	turnoff2 kinsno + 1, 4, 0
	if kactive == 0 then
		tablewkt 1, ksymbol, gisymbolon
		event "i", kinsno, 0, 3600
	endif
endif
;
;;Check for object updates
ktrigupdt, ksymbol, kxpos, kypos, kangle, kxspeed, kyspeed, krspeed, kmaccel, kraccel, ksession updateObject gituio

if ktrigupdt == 1 && ksymbol < 12 then
	tablewkt kxpos, 100, 200 + ksymbol
	tablewkt kypos, 101, 200 + ksymbol
	tablewkt kangle, 102, 200 + ksymbol
rireturn
endif
;
;; Check for object removal
ktrigrem, ksymbol, ksession removeObject gituio

if ktrigrem == 1 && ksymbol < 12 then
	kmode getParameter i(ksymbol), 0
	kinsno = 21 + (ksymbol/100)
	event "i", kinsno, 0, -1, kmode
endif

; Watchdog
knum active 1
ktrig changed knum
printf "Receiver count now %i\n", ktrig, knum

endin

instr 20 ;  symbol active
isymbol = round(frac(p1) *100)
xtratim ksmps/sr

kreleasing release

imode getParameter_i isymbol, 0

printf_i "turn on symbol %i mode %i\n", 1, isymbol, imode
cggoto (imode == 0), mode1
cggoto (imode == 1), mode2
cggoto (imode == 2), mode3
cggoto (imode == 3), mode4

mode1:
inote getParameter_i isymbol, 1
ialt getParameter_i isymbol, 2
ioct getParameter_i isymbol, 3
iveloc getParameter_i isymbol, 4
ichan getParameter_i isymbol, 5
kx getParameter isymbol,100
ky getParameter isymbol,101
kangle getParameter isymbol,102

inum noteToMidi_i inote, ialt, ioct
print inum, iveloc, ichan
noteon ichan, inum, iveloc

ckgoto (kreleasing == 0), CCs ; always skip "off" section
reinit mode1rel
igoto CCs
mode1rel: ; note
	printf_i "symbol off mode1: %i\n", 1, isymbol
	noteoff ichan, inum, 0
	rireturn
	goto CCs
mode2: ;control

ictl getParameter_i isymbol, 18
ichan getParameter_i isymbol, 19
imin getParameter_i isymbol, 20
imax getParameter_i isymbol, 21
kx getParameter isymbol,100
ky getParameter isymbol,101
kangle getParameter isymbol,102

print ichan, ictl, imax
outic ichan, ictl, imax, 0 , 127 ; This is not working here! why??
event_i "i", 31, 0, 0.1, ichan, ictl, imax
ckgoto (kreleasing == 0), CCs ; always skip "off" section
reinit mode2rel
igoto CCs
mode2rel: ; note
	printf_i "symbol off mode 2: %i -- %i %i %i\n", 1, isymbol,  ichan, ictl, imin
	outic ichan, ictl, imin, 0 , 127
	event_i "i", 31, 0, 0.1, ichan, ictl, imin
	rireturn
	goto CCs

mode3: ; arpegiator

kcount init 0

knote getParameter isymbol,22
kalt getParameter isymbol,23
koct getParameter isymbol,24
kveloc getParameter isymbol,25
kchn getParameter isymbol,26
kchrdtype getParameter isymbol,27
ktempo getParameter isymbol,28
ksubdiv getParameter isymbol,29
kstyle getParameter isymbol,30
knumnotes getParameter isymbol,31


kx getParameter isymbol,100
ky getParameter isymbol,101
kangle getParameter isymbol,102

ktempofactor table ksubdiv, gisubdiv
knotetrig metro ktempo*ktempofactor/60

kchanged changed kchrdtype
if kchanged == 1 then
	reinit calculate_arp_len
endif

calculate_arp_len:
iftlen = ftlen(400+i(kchrdtype))
if kstyle == 0 then
	kindex = kcount
	koct = koct + int(kindex/iftlen)
elseif kstyle == 1 then
	kindex = knumnotes - kcount
	koct = koct + int(knumnotes/iftlen) - int(kcount/iftlen)
elseif kstyle == 2 then
	if kcount < int(knumnotes/2) then
		kindex = kcount
		koct = koct + int(kindex/iftlen)
	else
		kindex = knumnotes - kcount
		koct = koct + int(knumnotes/iftlen)  - int(kcount/iftlen)
	endif
elseif kstyle == 3 then
	kindex = kcount
	koct = koct + int(kindex/iftlen)
	if kcount < knumnotes then
		knotetrig = 1 ; force triggering note
	else 
		knotetrig = 0 ; all notes have been triggered
	endif
endif

kst tablekt kindex%iftlen, 400+kchrdtype

kclass, kalt semitoneToClass kst
knum noteToMidi kclass, kalt, koct
schedkwhen knotetrig, 0, 32, 30, 0, 60/ktempo*ktempofactor, kchn, knum, kveloc
if knotetrig == 1 then
	kcount = kcount + 1
	if (kcount >= knumnotes) then
		if (kstyle != 3) then
			kcount = 0
		endif
	endif
endif

;ckgoto (kreleasing == 0), CCs ; always skip "off" section
;;reinit mode3rel
;igoto CCs
;mode3rel: ; note
;	printf_i "symbol off mode3: %i\n", 1, isymbol
;	rireturn
;	goto CCs

CCs:

kxcc getParameter isymbol, 6
kxchan getParameter isymbol, 7
kxmin getParameter isymbol, 8
kxmax getParameter isymbol, 9
printk2 kxcc
printk2 kxchan
if kxcc != 0 then 
	outkc kxchan, kxcc, 1-kx, kxmin/127, kxmax/127
endif

kycc getParameter isymbol, 10
kychan getParameter isymbol, 11
kymin getParameter isymbol, 12
kymax getParameter isymbol, 13
if kycc != 0 then
	outkc kychan, kycc, 1-ky, kymin/127, kymax/127
endif

kacc getParameter isymbol, 14
kachan getParameter isymbol, 15
kamin getParameter isymbol, 16
kamax getParameter isymbol, 17
if kacc != 0 then
	outkc kachan, kacc, kangle/(2*$M_PI), kamin/127, kamax/127
endif

goto aftermodes

mode4: ;harp
knote getParameter isymbol, 40
kalt getParameter isymbol, 41
koct getParameter isymbol, 42
kveloc getParameter isymbol, 43
kchan getParameter isymbol, 44
kscale getParameter isymbol, 45
knumnotes getParameter isymbol, 46
kharpmode getParameter isymbol, 47
kdur getParameter isymbol, 48

kx getParameter isymbol,100
ky getParameter isymbol,101
kangle getParameter isymbol,102

kchanged changed kscale
if kchanged == 1 then
	reinit calculate_len
endif

calculate_len:
iftlen = ftlen(300+i(kscale))

kx tonek (1-kx), 0.1
ky tonek (1-ky), 0.1
kaddoct = int(kx *knumnotes/iftlen)
kindex init (i(kx) *i(knumnotes))%iftlen
kindex = (kx *knumnotes)%iftlen
rireturn

;kindex portk kindex, 1
;kindex tonek kindex, 0.4

kclass tablekt int(kindex), 300+kscale, 0, 0, 1

ktrig changed kclass
knumbase noteToMidi knote, kalt, koct + kaddoct

schedkwhen ktrig, 0, 32, 30, 0, kdur, kchan, knumbase + kclass, kveloc*(0.25 + (ky*0.75))

aftermodes:

endin

instr 21 ; note off scheduler. Use fractional numbers to identify symbols
imode = p4
ih = i(gkhold) + (imode == 2 ? 1 : 0) ;arpeggiator sticks longer
iinstr = 20 + frac(p1)

tablewkt 0, round(frac(p1) * 100), gisymbolon
printf_i "turnoff note %f mode %f -- %i\n", 1, iinstr, imode, round(frac(p1) * 100)
timout ih, 1, destroysymbol
goto end
destroysymbol:
turnoff2 iinstr, 4, 1
turnoff

end:
endin

instr 30 ; midi note on dur
ichn = p4
inum = p5
ivel = p6
idur = p3
print inum
noteondur ichn, inum, ivel, idur
endin

instr 31 ; ctlout
print p4, p5, p6
outic p4, p5, p6, 0, 127
endin

</CsInstruments>
<CsScore>
; turnon symbols:
i 1 0 36000 0
i 1 0 36000 1
i 1 0 36000 2
i 1 0 36000 3
i 1 0 36000 4
i 1 0 36000 5
i 1 0 36000 6
i 1 0 36000 7
i 1 0 36000 8
i 1 0 36000 9
i 1 0 36000 10
i 1 0 36000 11

; TUIO receiver
i 10 0 36000

</CsScore>
</CsoundSynthesizer>

















<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>398</width>
 <height>359</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>155</x>
  <y>13</y>
  <width>220</width>
  <height>81</height>
  <uuid>{fa281053-bcd1-4d0a-80f7-701a48d05338}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>X</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_1</objectName>
  <x>19</x>
  <y>40</y>
  <width>49</width>
  <height>28</height>
  <uuid>{04866ad2-e565-4e98-a559-75ca32dbb2a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>C</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>D</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>E</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>F</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>G</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>A</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>B</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_2</objectName>
  <x>75</x>
  <y>39</y>
  <width>58</width>
  <height>26</height>
  <uuid>{59dca60b-9d7a-4bb0-aa15-789e195765d0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>nat</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sharp</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>flat</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_3</objectName>
  <x>31</x>
  <y>94</y>
  <width>38</width>
  <height>18</height>
  <uuid>{7a0c9bd5-5395-435e-9969-284232ade2ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>3.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>p0_5</objectName>
  <x>82</x>
  <y>119</y>
  <width>39</width>
  <height>24</height>
  <uuid>{22a9169b-f85c-45c2-9f77-0728fcc05e1f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>3</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>68</y>
  <width>53</width>
  <height>24</height>
  <uuid>{4595964c-f43f-4953-bc9a-2ebfbdc16145}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octave</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>75</x>
  <y>67</y>
  <width>49</width>
  <height>25</height>
  <uuid>{8c9fbb39-7d24-463c-917c-b2d864cdb0e4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Veloc</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_4</objectName>
  <x>78</x>
  <y>93</y>
  <width>44</width>
  <height>20</height>
  <uuid>{de7e4be5-f124-4ec9-a786-1d9b956f22f3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>21.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>26</x>
  <y>117</y>
  <width>49</width>
  <height>25</height>
  <uuid>{5725a2cd-43da-4990-b722-d1b8fac029e9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chan</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_0</objectName>
  <x>11</x>
  <y>10</y>
  <width>133</width>
  <height>22</height>
  <uuid>{c21fb2c4-ddbf-4a70-82a9-8410276509f2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>note</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>control</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>arp</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>harp</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_6</objectName>
  <x>169</x>
  <y>57</y>
  <width>38</width>
  <height>28</height>
  <uuid>{359ecc17-b233-4c7f-921b-766617b024ec}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>159</x>
  <y>31</y>
  <width>53</width>
  <height>24</height>
  <uuid>{6effc8db-e8d9-4406-aee0-fadb8610e993}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CC Num</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>213</x>
  <y>30</y>
  <width>49</width>
  <height>25</height>
  <uuid>{12849cdc-7fb2-4268-9a18-e531c1df21d6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chn</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_7</objectName>
  <x>216</x>
  <y>56</y>
  <width>44</width>
  <height>30</height>
  <uuid>{0085d626-1a73-4e7a-b28b-98898cfcb952}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>1.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>16.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_8</objectName>
  <x>273</x>
  <y>57</y>
  <width>38</width>
  <height>28</height>
  <uuid>{3546ee88-5e90-4ae4-94f3-63e06d5b6f65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>264</x>
  <y>31</y>
  <width>53</width>
  <height>24</height>
  <uuid>{49266f8d-ef3f-46b2-9d1b-910fa8ce12a6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Min</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>318</x>
  <y>30</y>
  <width>49</width>
  <height>25</height>
  <uuid>{707dd683-7175-4c84-a9c2-744c43427868}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Max</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_9</objectName>
  <x>321</x>
  <y>56</y>
  <width>44</width>
  <height>30</height>
  <uuid>{fb71b077-87e7-434a-96b2-5e280298763c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>127.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>155</x>
  <y>98</y>
  <width>222</width>
  <height>78</height>
  <uuid>{0ebe88f6-4bf9-46dd-8494-c0bddde34b75}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Y</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_10</objectName>
  <x>170</x>
  <y>140</y>
  <width>38</width>
  <height>28</height>
  <uuid>{5f4f31ac-0825-411c-9112-7aad78ca2ca6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>160</x>
  <y>114</y>
  <width>53</width>
  <height>24</height>
  <uuid>{df4c7a7d-118a-45fd-9b04-e193f344536e}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CC Num</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>214</x>
  <y>113</y>
  <width>49</width>
  <height>25</height>
  <uuid>{4b09e534-fd9b-4858-bf31-642ed33bade9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chn</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_11</objectName>
  <x>217</x>
  <y>138</y>
  <width>44</width>
  <height>30</height>
  <uuid>{fae5fb5f-7b8e-46fb-995f-5d965e85eb6f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>1.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>16.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_12</objectName>
  <x>275</x>
  <y>140</y>
  <width>38</width>
  <height>28</height>
  <uuid>{632a3a4b-2858-4ca3-8749-e1409915e214}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>265</x>
  <y>114</y>
  <width>53</width>
  <height>24</height>
  <uuid>{942b2705-aaad-4041-a6bd-8fff48ca7728}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Min</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>319</x>
  <y>113</y>
  <width>49</width>
  <height>25</height>
  <uuid>{3a284659-a303-449b-9279-83fff0827636}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Max</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_13</objectName>
  <x>323</x>
  <y>139</y>
  <width>44</width>
  <height>30</height>
  <uuid>{9d8c1cd6-bb8f-4868-a947-124ad7289b06}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>154</x>
  <y>181</y>
  <width>222</width>
  <height>78</height>
  <uuid>{228c2ec7-9046-4693-87e1-ac44029fc51c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Angle</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_14</objectName>
  <x>170</x>
  <y>225</y>
  <width>38</width>
  <height>28</height>
  <uuid>{4989003a-cedc-45e9-8a17-7f3035cac838}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>160</x>
  <y>199</y>
  <width>53</width>
  <height>24</height>
  <uuid>{aece14fc-12c7-492c-8fa6-df2af5886ad6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CC Num</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>214</x>
  <y>198</y>
  <width>49</width>
  <height>25</height>
  <uuid>{0aa1f09a-013c-4f3e-b252-10ad88c7732d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chn</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_15</objectName>
  <x>217</x>
  <y>224</y>
  <width>44</width>
  <height>30</height>
  <uuid>{b1661a61-452f-42d6-91df-9d8cf263c0b1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>1.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>16.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_16</objectName>
  <x>274</x>
  <y>225</y>
  <width>38</width>
  <height>28</height>
  <uuid>{9367115e-7f57-4aee-8913-907af9412f13}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>265</x>
  <y>199</y>
  <width>53</width>
  <height>24</height>
  <uuid>{3cec585d-4a27-4a23-b6b0-6984224b62bd}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Min</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>319</x>
  <y>198</y>
  <width>49</width>
  <height>25</height>
  <uuid>{56487ded-55d4-4f64-b57f-5813b05e6ed8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Max</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_17</objectName>
  <x>322</x>
  <y>224</y>
  <width>44</width>
  <height>30</height>
  <uuid>{a3c8f859-4455-4584-a53d-c56cab61ebc7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>0.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>13</x>
  <y>144</y>
  <width>123</width>
  <height>117</height>
  <uuid>{85c651af-b55d-4348-a1b2-e3b1d53aa42b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Control Mode</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_18</objectName>
  <x>28</x>
  <y>185</y>
  <width>39</width>
  <height>20</height>
  <uuid>{788413bc-5262-4b7a-86a3-2260b6ca965f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>27.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>21</x>
  <y>166</y>
  <width>53</width>
  <height>24</height>
  <uuid>{1450b40d-b699-4cf4-b2cf-dbd091f3737b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>CC Num</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>75</x>
  <y>165</y>
  <width>49</width>
  <height>25</height>
  <uuid>{0d95cbee-8ef6-4286-82ff-23396b9d1fd3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chn</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_19</objectName>
  <x>78</x>
  <y>181</y>
  <width>45</width>
  <height>22</height>
  <uuid>{3497c86e-7a2f-42f1-92f7-8a2a0aaa40f6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>1.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_20</objectName>
  <x>31</x>
  <y>224</y>
  <width>39</width>
  <height>20</height>
  <uuid>{f5963e58-20b9-412a-8075-3b92f2fcd030}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>2.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>23</x>
  <y>202</y>
  <width>54</width>
  <height>23</height>
  <uuid>{d8fba63a-20c9-4bd8-a940-8b396883ad8a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Min</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>73</x>
  <y>200</y>
  <width>50</width>
  <height>24</height>
  <uuid>{82fd8c61-2653-4de6-a924-cbc573106647}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Max</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_21</objectName>
  <x>79</x>
  <y>220</y>
  <width>45</width>
  <height>22</height>
  <uuid>{b3ec70da-cb0d-4e11-9ed8-5638d5940de7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>94.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_27</objectName>
  <x>141</x>
  <y>342</y>
  <width>80</width>
  <height>30</height>
  <uuid>{d5f12c35-b7d8-4e6e-84c3-bb377326fb49}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>major</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>minor</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>7</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>m7</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>maj7</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>5</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sus4</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_40</objectName>
  <x>12</x>
  <y>495</y>
  <width>49</width>
  <height>28</height>
  <uuid>{dcc707e8-2340-4e88-a5f0-94c364393956}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>C</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>D</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>E</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>F</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>G</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>A</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>B</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_41</objectName>
  <x>68</x>
  <y>494</y>
  <width>58</width>
  <height>26</height>
  <uuid>{116c92ac-c90a-4a7d-898a-03656d4a3476}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>nat</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sharp</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>flat</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_42</objectName>
  <x>21</x>
  <y>541</y>
  <width>38</width>
  <height>18</height>
  <uuid>{7c35bc20-4989-4495-861a-37a14ab586a1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>4.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>p0_44</objectName>
  <x>71</x>
  <y>558</y>
  <width>39</width>
  <height>24</height>
  <uuid>{0ff337b9-6319-4a55-a07f-1534e7877606}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>14</x>
  <y>523</y>
  <width>53</width>
  <height>24</height>
  <uuid>{3b889aac-dbd8-44ff-9d9f-6715f1b764ef}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octave</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>68</x>
  <y>522</y>
  <width>49</width>
  <height>25</height>
  <uuid>{69ac93ed-71a3-49d1-815a-f978d5528dc2}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Veloc</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_43</objectName>
  <x>68</x>
  <y>540</y>
  <width>44</width>
  <height>20</height>
  <uuid>{8128b832-f216-4a21-929c-99cec15d3782}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>94.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>15</x>
  <y>556</y>
  <width>49</width>
  <height>25</height>
  <uuid>{64e9bdf0-1e8f-4354-944b-1a42a1d5c44c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chan</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_45</objectName>
  <x>150</x>
  <y>503</y>
  <width>80</width>
  <height>30</height>
  <uuid>{3a1a7483-3211-4c9f-b36f-2f5916a143f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>major</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>minor</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>pentatonic</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>dblharm</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>p0_46</objectName>
  <x>193</x>
  <y>552</y>
  <width>39</width>
  <height>24</height>
  <uuid>{9eab7d85-99b4-4336-ad51-dc44759e3830}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>49</maximum>
  <randomizable group="0">false</randomizable>
  <value>19</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>240</x>
  <y>555</y>
  <width>41</width>
  <height>21</height>
  <uuid>{083bd869-7fc5-417f-8067-f35db332c987}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Dur</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>p0_48</objectName>
  <x>280</x>
  <y>553</y>
  <width>56</width>
  <height>24</height>
  <uuid>{9a240e02-bb2e-4e95-afd1-2f5b727c0696}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>0.05000000</resolution>
  <minimum>0</minimum>
  <maximum>2</maximum>
  <randomizable group="0">false</randomizable>
  <value>2</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>127</x>
  <y>552</y>
  <width>67</width>
  <height>24</height>
  <uuid>{3913e536-b376-4f9a-b3dd-47293b6aa431}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Num notes</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_22</objectName>
  <x>13</x>
  <y>344</y>
  <width>49</width>
  <height>28</height>
  <uuid>{142f2cf5-3b26-43ae-ac3c-9d062f2c5572}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>C</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>D</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>E</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>F</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>G</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>A</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>B</name>
    <value>6</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_23</objectName>
  <x>69</x>
  <y>343</y>
  <width>58</width>
  <height>26</height>
  <uuid>{09276765-1666-4ec6-8540-e6376da2b942}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>nat</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>sharp</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>flat</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>0</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_24</objectName>
  <x>22</x>
  <y>390</y>
  <width>38</width>
  <height>18</height>
  <uuid>{c5273446-caf7-45ab-bc80-3afb3d413a64}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>4.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>0.00000000</minimum>
  <maximum>8.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>p0_26</objectName>
  <x>72</x>
  <y>407</y>
  <width>39</width>
  <height>24</height>
  <uuid>{6a200b7d-df24-4cbc-85a5-6c6b7ed53f9c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>16</maximum>
  <randomizable group="0">false</randomizable>
  <value>1</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>15</x>
  <y>372</y>
  <width>53</width>
  <height>24</height>
  <uuid>{55d646af-c8fb-4441-9749-321fcb1ffe8b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Octave</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>69</x>
  <y>371</y>
  <width>49</width>
  <height>25</height>
  <uuid>{a2114941-1e49-489e-a515-74a981e0c330}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Veloc</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBScrollNumber">
  <objectName>p0_25</objectName>
  <x>69</x>
  <y>389</y>
  <width>44</width>
  <height>20</height>
  <uuid>{24ab7858-549b-4200-a4b2-0d99bee3fae3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="background">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <value>42.00000000</value>
  <resolution>1.00000000</resolution>
  <minimum>1.00000000</minimum>
  <maximum>127.00000000</maximum>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
  <randomizable group="0">false</randomizable>
  <mouseControl act=""/>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>16</x>
  <y>405</y>
  <width>49</width>
  <height>25</height>
  <uuid>{6f623ed9-fd3e-44d1-8bbf-adf85fe5d75a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Chan</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>137</x>
  <y>381</y>
  <width>48</width>
  <height>21</height>
  <uuid>{d025f969-913e-4157-8ddc-25cf00b1ca26}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Tempo</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>p0_28</objectName>
  <x>181</x>
  <y>379</y>
  <width>56</width>
  <height>24</height>
  <uuid>{50aa0a6c-9969-43e0-a0b5-6a1fff050e35}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>0.10000000</resolution>
  <minimum>40</minimum>
  <maximum>250</maximum>
  <randomizable group="0">false</randomizable>
  <value>60</value>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_29</objectName>
  <x>145</x>
  <y>407</y>
  <width>80</width>
  <height>27</height>
  <uuid>{36b4da09-964d-44d7-b8ed-23e879a7e7ce}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>4</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>2</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1/2</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1/3</name>
    <value>4</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>1/4</name>
    <value>5</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>3</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDropdown">
  <objectName>p0_30</objectName>
  <x>254</x>
  <y>342</y>
  <width>80</width>
  <height>27</height>
  <uuid>{844fce24-1035-4862-8c22-3ca44a58c819}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <bsbDropdownItemList>
   <bsbDropdownItem>
    <name>up</name>
    <value>0</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>down</name>
    <value>1</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>up-down</name>
    <value>2</value>
    <stringvalue/>
   </bsbDropdownItem>
   <bsbDropdownItem>
    <name>chord</name>
    <value>3</value>
    <stringvalue/>
   </bsbDropdownItem>
  </bsbDropdownItemList>
  <selectedIndex>2</selectedIndex>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBSpinBox">
  <objectName>p0_31</objectName>
  <x>304</x>
  <y>410</y>
  <width>39</width>
  <height>24</height>
  <uuid>{88caa428-8708-44be-b721-b3cd270a8923}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>1</minimum>
  <maximum>49</maximum>
  <randomizable group="0">false</randomizable>
  <value>8</value>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>238</x>
  <y>410</y>
  <width>67</width>
  <height>24</height>
  <uuid>{ef7c569a-8b4c-4222-b832-a61cad8f11f9}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Num notes</label>
  <alignment>left</alignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
