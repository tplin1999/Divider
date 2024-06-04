*** Divider ***
.param l_min = 90n
.param w_min = 0.2u
.param w_p = 3*w_min
.param w_n = 1*w_min

.subckt	inv	in	out	vdd
mp0	out	in	vdd	vdd	pmos	l=l_min  w=w_p
mn0  	out  	in  	gnd  	gnd  	nmos  	l=l_min  w=w_n
.ends

.subckt or	a       b       out	vdd
mp0  	net1  	a  	vdd  	vdd  	pmos  	l=l_min  w=w_p
mp1  	outb  	b  	net1  	vdd  	pmos  	l=l_min  w=w_p
mn0  	outb  	a  	gnd  	gnd  	nmos  	l=l_min  w=w_n
mn1  	outb  	b  	gnd  	gnd  	nmos  	l=l_min  w=w_n
xinv0	outb	out	vdd	inv
.ends

.subckt and	a       b       out	vdd
mp0  	outb  	a  	vdd  	vdd  	pmos  	l=l_min  w=w_p
mp1  	outb  	b  	vdd  	vdd  	pmos  	l=l_min  w=w_p
mn0  	outb  	a  	net1  	gnd  	nmos  	l=l_min  w=w_n
mn1  	net1  	b  	gnd  	gnd  	nmos  	l=l_min  w=w_n
xinv0	outb	out	vdd	inv
.ends

.subckt	dff	d       ck      Q	Qb 	vdd
xinv0   ck	ckb	vdd     inv
mn0     d       ckb     net1    gnd     nmos  	l=l_min  w=w_n
mp0     d       ck      net1    vdd     pmos	l=l_min	 w=w_p
xinv1   net1    A	vdd     inv
xinv2   A      	Ab	vdd     inv
mn1     Ab    	ck     	net1    gnd     nmos  	l=l_min  w=w_n
mp1     Ab    	ckb     net1    vdd     pmos  	l=l_min  w=w_p

mn2     A    	ck     	net2    gnd     nmos  	l=l_min  w=w_n
mp2     A    	ckb     net2    vdd     pmos  	l=l_min  w=w_p
xinv3   net2	Q	vdd     inv
xinv4   Q	Qb	vdd     inv
mn3     Qb    	ckb     net2    gnd     nmos  	l=l_min  w=w_n
mp3     Qb    	ck     	net2    vdd     pmos  	l=l_min  w=w_p
.ends

.subckt	buffer  in      out     vdd
xinv0   in	net0	vdd     inv
xinv1   net0	net1	vdd     inv
xinv2   net1	net2	vdd     inv
xinv3   net2	net3	vdd     inv
xinv4   net3	net4	vdd     inv
xinv5   net4	net5	vdd     inv
xinv6   net5	net6	vdd     inv
xinv7   net6	out	vdd     inv
.ends

.subckt	tapper_buffer  in      out     vdd
xinv0   in	net0	vdd     inv
xinv1   net0	net1	vdd     inv
xinv2   net1	net2	vdd     inv
xinv3   net2	net3	vdd     inv
xinv4   net3	net4	vdd     inv
xinv5   net4	out	vdd     inv
.ends

.subckt	div_3	ck	f3	vdd
xinv1	ck	ckb	vdd	inv
xd1	D1	ck	Q1	Q1b	vdd	dff
xd2	Q1	ck	Q2	Q2b	vdd	dff
xd3	Q2	ckb	Q3	Q3b	vdd	dff
xand1	Q1b	Q2b	D1	vdd	and
xor1	Q2	Q3	f3	vdd	or
.ends

.subckt	div_6	ck	f6	vdd
xdiv_3	ck	f3	vdd	div_3
xd1	f6b	f3	f6	f6b	vdd	dff
.ends

.subckt	div_8	ck	f8	vdd
xd1	f2b	ck	f2	f2b	vdd	dff
xd2	f4b	f2b	f4	f4b	vdd	dff
xd3	f8b	f4b	f8	f8b	vdd	dff
.ends

*** main ***
VDD     vdd     gnd     dc=1V
Vck     ck   gnd     pulse(0 1 0n 0.001n 0.001n 0.21n 0.42n)

xbuffer	ck	ck_buf	vdd	buffer
xdiv_3	ck_buf	f3_og	vdd	div_3
xdiv_6	ck_buf	f6_og	vdd	div_6
xdiv_8	ck_buf	f8_og	vdd	div_8

xtap_3	f3_og	f3	vdd	tapper_buffer
xtap_6	f6_og	f6	vdd	tapper_buffer
xtap_8	f8_og	f8	vdd	tapper_buffer

c3	f3	gnd	50f
c6	f6	gnd	50f
c8	f8	gnd	50f

*** setting ***
.tran 0.01ns 8ns start=0

.options POST=2
.options AUTOSTOP
.options INGOLD=2     DCON=1
.options GSHUNT=1e-12 RMIN=1e-15
.options ABSTOL=1e-5  ABSVDC=1e-4
.options RELTOL=1e-2  RELVDC=1e-2
.options NUMDGT=4 PIVOT=13
.options runlvl=6
.temp 40

*** power consumption ***
.meas tran T1 when V(ck)=0.9 rise=15
.meas tran T2 when V(ck)=0.9 rise=16
.meas Td param="T2-T1" 
.meas tran Power avg power from T1 to T2
.meas Score param="((10^(-9))/(Td*Power))"

*** library ***
* PTM 90nm NMOS 
.model  nmos  nmos  level = 54

+version = 4.0          binunit = 1            paramchk= 1            mobmod  = 0          
+capmod  = 2            igcmod  = 1            igbmod  = 1            geomod  = 1          
+diomod  = 1            rdsmod  = 0            rbodymod= 1            rgatemod= 1          
+permod  = 1            acnqsmod= 0            trnqsmod= 0          

+tnom    = 27           toxe    = 2.05e-9      toxp    = 1.4e-9       toxm    = 2.05e-9   
+dtox    = 0.65e-9      epsrox  = 3.9          wint    = 5e-009       lint    = 7.5e-009   
+ll      = 0            wl      = 0            lln     = 1            wln     = 1          
+lw      = 0            ww      = 0            lwn     = 1            wwn     = 1          
+lwl     = 0            wwl     = 0            xpart   = 0            toxref  = 2.05e-9   
+xl      = -40e-9
+vth0    = 0.397        k1      = 0.4          k2      = 0.01         k3      = 0          
+k3b     = 0            w0      = 2.5e-006     dvt0    = 1            dvt1    = 2       
+dvt2    = -0.032       dvt0w   = 0            dvt1w   = 0            dvt2w   = 0          
+dsub    = 0.1          minv    = 0.05         voffl   = 0            dvtp0   = 1.2e-009     
+dvtp1   = 0.1          lpe0    = 0            lpeb    = 0            xj      = 2.8e-008   
+ngate   = 2e+020       ndep    = 1.94e+018    nsd     = 2e+020       phin    = 0          
+cdsc    = 0.0002       cdscb   = 0            cdscd   = 0            cit     = 0          
+voff    = -0.13        nfactor = 1.7          eta0    = 0.0074       etab    = 0          
+vfb     = -0.55        u0      = 0.0547       ua      = 6e-010       ub      = 1.2e-018     
+uc      = -3e-011      vsat    = 113760       a0      = 1.0          ags     = 1e-020     
+a1      = 0            a2      = 1            b0      = -1e-020      b1      = 0          
+keta    = 0.04         dwg     = 0            dwb     = 0            pclm    = 0.06       
+pdiblc1 = 0.001        pdiblc2 = 0.001        pdiblcb = -0.005       drout   = 0.5        
+pvag    = 1e-020       delta   = 0.01         pscbe1  = 8.14e+008    pscbe2  = 1e-007     
+fprout  = 0.2          pdits   = 0.08         pditsd  = 0.23         pditsl  = 2.3e+006   
+rsh     = 5            rdsw    = 180          rsw     = 90           rdw     = 90        
+rdswmin = 0            rdwmin  = 0            rswmin  = 0            prwg    = 0          
+prwb    = 6.8e-011     wr      = 1            alpha0  = 0.074        alpha1  = 0.005      
+beta0   = 30           agidl   = 0.0002       bgidl   = 2.1e+009     cgidl   = 0.0002     
+egidl   = 0.8          

+aigbacc = 0.012        bigbacc = 0.0028       cigbacc = 0.002     
+nigbacc = 1            aigbinv = 0.014        bigbinv = 0.004        cigbinv = 0.004      
+eigbinv = 1.1          nigbinv = 3            aigc    = 0.012        bigc    = 0.0028     
+cigc    = 0.002        aigsd   = 0.012        bigsd   = 0.0028       cigsd   = 0.002     
+nigc    = 1            poxedge = 1            pigcd   = 1            ntox    = 1          

+xrcrg1  = 12           xrcrg2  = 5          
+cgso    = 1.9e-010     cgdo    = 1.9e-010     cgbo    = 2.56e-011    cgdl    = 2.653e-10     
+cgsl    = 2.653e-10    ckappas = 0.03         ckappad = 0.03         acde    = 1          
+moin    = 15           noff    = 0.9          voffcv  = 0.02       

+kt1     = -0.11        kt1l    = 0            kt2     = 0.022        ute     = -1.5       
+ua1     = 4.31e-009    ub1     = 7.61e-018    uc1     = -5.6e-011    prt     = 0          
+at      = 33000      

+fnoimod = 1            tnoimod = 0          

+jss     = 0.0001       jsws    = 1e-011       jswgs   = 1e-010       njs     = 1          
+ijthsfwd= 0.01         ijthsrev= 0.001        bvs     = 10           xjbvs   = 1          
+jsd     = 0.0001       jswd    = 1e-011       jswgd   = 1e-010       njd     = 1          
+ijthdfwd= 0.01         ijthdrev= 0.001        bvd     = 10           xjbvd   = 1          
+pbs     = 1            cjs     = 0.0005       mjs     = 0.5          pbsws   = 1          
+cjsws   = 5e-010       mjsws   = 0.33         pbswgs  = 1            cjswgs  = 3e-010     
+mjswgs  = 0.33         pbd     = 1            cjd     = 0.0005       mjd     = 0.5        
+pbswd   = 1            cjswd   = 5e-010       mjswd   = 0.33         pbswgd  = 1          
+cjswgd  = 5e-010       mjswgd  = 0.33         tpb     = 0.005        tcj     = 0.001      
+tpbsw   = 0.005        tcjsw   = 0.001        tpbswg  = 0.005        tcjswg  = 0.001      
+xtis    = 3            xtid    = 3          

+dmcg    = 0e-006       dmci    = 0e-006       dmdg    = 0e-006       dmcgt   = 0e-007     
+dwj     = 0.0e-008     xgw     = 0e-007       xgl     = 0e-008     

+rshg    = 0.4          gbmin   = 1e-010       rbpb    = 5            rbpd    = 15         
+rbps    = 15           rbdb    = 15           rbsb    = 15           ngcon   = 1          

* PTM 90nm PMOS
 
.model  pmos  pmos  level = 54

+version = 4.0          binunit = 1            paramchk= 1            mobmod  = 0          
+capmod  = 2            igcmod  = 1            igbmod  = 1            geomod  = 1          
+diomod  = 1            rdsmod  = 0            rbodymod= 1            rgatemod= 1          
+permod  = 1            acnqsmod= 0            trnqsmod= 0          

+tnom    = 27           toxe    = 2.15e-009    toxp    = 1.4e-009     toxm    = 2.15e-009   
+dtox    = 0.75e-9      epsrox  = 3.9          wint    = 5e-009       lint    = 7.5e-009   
+ll      = 0            wl      = 0            lln     = 1            wln     = 1          
+lw      = 0            ww      = 0            lwn     = 1            wwn     = 1          
+lwl     = 0            wwl     = 0            xpart   = 0            toxref  = 2.15e-009   
+xl      = -40e-9
+vth0    = -0.339       k1      = 0.4          k2      = -0.01        k3      = 0          
+k3b     = 0            w0      = 2.5e-006     dvt0    = 1            dvt1    = 2       
+dvt2    = -0.032       dvt0w   = 0            dvt1w   = 0            dvt2w   = 0          
+dsub    = 0.1          minv    = 0.05         voffl   = 0            dvtp0   = 1e-009     
+dvtp1   = 0.05         lpe0    = 0            lpeb    = 0            xj      = 2.8e-008   
+ngate   = 2e+020       ndep    = 1.43e+018    nsd     = 2e+020       phin    = 0          
+cdsc    = 0.000258     cdscb   = 0            cdscd   = 6.1e-008     cit     = 0          
+voff    = -0.126       nfactor = 1.7          eta0    = 0.0074       etab    = 0          
+vfb     = 0.55         u0      = 0.00711      ua      = 2.0e-009     ub      = 0.5e-018     
+uc      = -3e-011      vsat    = 70000        a0      = 1.0          ags     = 1e-020     
+a1      = 0            a2      = 1            b0      = 0            b1      = 0          
+keta    = -0.047       dwg     = 0            dwb     = 0            pclm    = 0.12       
+pdiblc1 = 0.001        pdiblc2 = 0.001        pdiblcb = 3.4e-008     drout   = 0.56       
+pvag    = 1e-020       delta   = 0.01         pscbe1  = 8.14e+008    pscbe2  = 9.58e-007  
+fprout  = 0.2          pdits   = 0.08         pditsd  = 0.23         pditsl  = 2.3e+006   
+rsh     = 5            rdsw    = 200          rsw     = 100          rdw     = 100        
+rdswmin = 0            rdwmin  = 0            rswmin  = 0            prwg    = 3.22e-008  
+prwb    = 6.8e-011     wr      = 1            alpha0  = 0.074        alpha1  = 0.005      
+beta0   = 30           agidl   = 0.0002       bgidl   = 2.1e+009     cgidl   = 0.0002     
+egidl   = 0.8          

+aigbacc = 0.012        bigbacc = 0.0028       cigbacc = 0.002     
+nigbacc = 1            aigbinv = 0.014        bigbinv = 0.004        cigbinv = 0.004      
+eigbinv = 1.1          nigbinv = 3            aigc    = 0.69         bigc    = 0.0012     
+cigc    = 0.0008       aigsd   = 0.0087       bigsd   = 0.0012       cigsd   = 0.0008     
+nigc    = 1            poxedge = 1            pigcd   = 1            ntox    = 1 
         
+xrcrg1  = 12           xrcrg2  = 5          
+cgso    = 1.8e-010     cgdo    = 1.8e-010     cgbo    = 2.56e-011    cgdl    = 2.653e-10
+cgsl    = 2.653e-10    ckappas = 0.03         ckappad = 0.03         acde    = 1
+moin    = 15           noff    = 0.9          voffcv  = 0.02

+kt1     = -0.11        kt1l    = 0            kt2     = 0.022        ute     = -1.5       
+ua1     = 4.31e-009    ub1     = 7.61e-018    uc1     = -5.6e-011    prt     = 0          
+at      = 33000      

+fnoimod = 1            tnoimod = 0          

+jss     = 0.0001       jsws    = 1e-011       jswgs   = 1e-010       njs     = 1          
+ijthsfwd= 0.01         ijthsrev= 0.001        bvs     = 10           xjbvs   = 1          
+jsd     = 0.0001       jswd    = 1e-011       jswgd   = 1e-010       njd     = 1          
+ijthdfwd= 0.01         ijthdrev= 0.001        bvd     = 10           xjbvd   = 1          
+pbs     = 1            cjs     = 0.0005       mjs     = 0.5          pbsws   = 1          
+cjsws   = 5e-010       mjsws   = 0.33         pbswgs  = 1            cjswgs  = 3e-010     
+mjswgs  = 0.33         pbd     = 1            cjd     = 0.0005       mjd     = 0.5        
+pbswd   = 1            cjswd   = 5e-010       mjswd   = 0.33         pbswgd  = 1          
+cjswgd  = 5e-010       mjswgd  = 0.33         tpb     = 0.005        tcj     = 0.001      
+tpbsw   = 0.005        tcjsw   = 0.001        tpbswg  = 0.005        tcjswg  = 0.001      
+xtis    = 3            xtid    = 3          

+dmcg    = 0e-006       dmci    = 0e-006       dmdg    = 0e-006       dmcgt   = 0e-007     
+dwj     = 0.0e-008     xgw     = 0e-007       xgl     = 0e-008     

+rshg    = 0.4          gbmin   = 1e-010       rbpb    = 5            rbpd    = 15         
+rbps    = 15           rbdb    = 15           rbsb    = 15           ngcon   = 1

.end