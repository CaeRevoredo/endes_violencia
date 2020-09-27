clear all
cd "C:\Users\user\Documents\endes"
****
u rech4, clear
rename _all, lower
***idxh4 y hhidx es igual a hc0 por lo que es necesario renombrar para el merge
rename idxh4 hc0
save rech4, replace

********<<<<<<<<<<Desde aquí
*** Información a nivel de hogar
u rech23, clear
merge 1:1 hhid using rech0, nogen
save rech23_0, replace
*** Información a nivel de individuos
u rech1, clear
rename hvidx hc0
merge 1:1 hhid hc0 using rech4, nogen
merge 1:1 hhid hc0 using rech6
rename _m rech6
save rech1_46, replace
merge m:1 hhid using rech23_0
**mod programas sociales
rename _merge rechf
merge m:1 hhid using progsoc
**violencia
rename _merge repro
g id="  "
egen caseid=concat(hhid id hc0)
merge m:1 caseid using re84dv
**mod muj
rename _merge viol
merge m:1 caseid using rec0111

save rechf, replace


**generando variables
g peso=hv005/1000000
g peso2=v005/1000000

rename hv025 area
label define area 1 "urbano" 2 "rural"
label value area area

label define shregion 1 "lima metropolitana" 2 "resto costa" 3 "sierra" 4 "selva"
label values shregion shregion
label var shregion "region natural"


g ambito=0
replace ambito=1 if shregion==1
replace ambito=2 if shregion==2
replace ambito=3 if shregion==3 & area==1
replace ambito=4 if shregion==3 & area==2
replace ambito=5 if shregion==4 & area==1
replace ambito=6 if shregion==4 & area==2
label def ambito 1 "lima metropolitana" 2 "resto costa" 3 "sierra urbana"  4 "sierra rural" 5 "selva urbana" 6 "selva rural"
label values ambito ambito
label var ambito "dominio geográfico"


g dpto = real(substr(ubigeo,1,2))
replace dpto=15 if (dpto==7)

label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" 12"Junin" 13"La Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martin" 23"Tacna" 24"Tumbes" 25"Ucayali" 
label values dpto dpto


****
***ELECTRICIDAD
fre hv206 [iw=peso] if hv101==1 

tab hv206 if hv101==1

svyset hv001 [w=peso], strata(hv022)
svy:proportion hv206 if hv101==1 

***AGUA TRATADA
*proviene de la red pública o de aquella que no proviniendo de la red pública le dan algún tratamiento en el hogar antes de beberla; tal como: la hierven, clorifican, desinfectan solamente, o consumen agua embotellada. 
replace hv201=hv202 if hv201==.
g agua=(hv201==11 | (hv201>11 & sh227<3)) | (hv201==11 | (hv201>11 & (hv237a==1 | hv237b==1 | hv237e==1))) | hv201==71
tab agua [iw=peso] if hv101==1
tab area agua [iw=peso] if hv101==1, row nofreq
***CASI TERMINADO

***SANEAMIENTO BÁSICO***casos sin ponderar coincide con excel articulado nutricional
fre hv205
recode hv205 (11/23=1 "con saneamiento") (24/96=0 "sin saneamiento"), g(desa)
tab desa [iw=peso] if hv101==1

table area [aw=peso] if hv101==1, c(m desa) f(%9.3f) row
*dominio de residencia
table shregion [aw=peso] if hv101==1, c(m desa) f(%9.3f) row
*ambito geográfico
table ambito [aw=peso] if hv101==1, c(m desa) f(%9.3f) row
*riqueza
table hv270 [aw=peso] if hv101==1, c(m desa) f(%9.3f) row
*departamentos
table dpto [aw=peso] if hv101==1, c(m desa) f(%9.3f) row










**dci
g desnwho=1 if hc70<-200 & hv103==1
replace desnwho=0 if hc70>=-200 & hc70<601 & hv103==1
label define desnwho 1 "con desnutrición crónica" 0 "sin desnutrición crónica"
label value desnwho desnwho
tab desnwho [iw=peso]
*total y por área de residencia
tab area desnwho [iw=peso], row
**sin ponderar --> ver cuadro 2 dc oms articulado nutricional
tab area desnwho, row
table area [aw=peso], c(m desnwho) f(%9.3f)
*región natural
table shregion [aw=peso], c (m desnwho) f(%9.3f) row
table shregion, c (m desnwho) f(%9.3f) row

**educ de la madre -> excluye los niños cuyas madres no residen en la vivienda ***INCOMPLETO
recode hc61 (0/1=1 "Sin nivel/prima") (2=2 "secundaria") (3=3 "superior") (.=.) (.a=.), g(educ)
table educ [aw=peso], c (m desnwho) f(%9.3f) row

*quintil de bienestar o riqueza
table hv270 [aw=peso] , c (m desnwho) f(%9.3f) row

***juntos
tab desnwho[iw=peso] if qh95==1

*sexo
table hv104 [aw=peso], c (m desnwho) f(%9.3f) row
**por meses
recode hc1 (0/5=1 "< a 6") (6/8=2 "6 a 8") (9/11=3 "9 a 11") (12/17=4 "12 a 17") (18/23=5 "18 a 23") (24/35=6 "24 a 35") (36/47=7 "36 a 47") (48/59=8), g(mes)

table mes [aw=peso], c (m desnwho) f(%9.3f) row


table dpto [aw=peso], c (m desnwho) f(%9.3f) row

****desnutrición crónica severa
g dcs=1 if hc70<-300 & hv103==1
replace dcs=0 if hc70>=-300 & hc70<601 & hv103==1

tab dcs [iw=peso]


***establecemos el diseño muestral
svyset hv001 [w=peso], strata(hv022)

**descriptivos de la variable pobre tomando en cuenta el diseño muestral
svy:proportion desnwho
svy:proportion desnwho if area==1
svy:proportion desnwho if area==2
svy, over(area): proportion desnwho
svy, over(shregion): proportion desnwho
***a partir de con dc lima met es el porcentaje de niños con dc por región natural
svy, over(ambito): proportion desnwho




****ANEMIA
***
*Creando la variable anemia
recode hc1 (6/35=1) (else=0), g(meses)

g alt=(hv040/1000)*3.3
g HAj= hc53/10 -(-0.032*alt+0.022*alt*alt)
recode HAj (1/10.99999=1 "anemia") (11/30=0 "no anemia"), g(anemia)

tab anemia [iw=peso] if hv103==1 & meses==1

*****
*cuadro 10.14b del cap_10, excel del inei no considera razón de no medición (hc13)
*observar Sin ponderar, en niveles las cantidad coindicen
tab area anemia if hv103==1 & meses==1, row
*con ponderador también coinciden
tab area anemia [iw=peso] if hv103==1 & meses==1, row

**por region natural
table shregion [iw=peso] if hv103==1 & meses==1, c(m anemia) row f(%9.3f)
***por dpto
table dpto [aw=peso] if hv103==1 & meses==1, c (m anemia) f(%9.5f) row

**área de residencia
table area [iw=peso] if hv103==1 & meses==1, c(m anemia) row f(%9.3f)

**meses (pestaña 10.13A)
recode hc1 (6/8=1 "6 a 8") (9/11=2 "9 a 11") (12/17=3 "12 a 17") (18/23=4 "18 a 23") (24/35=5 "24 a 35"), g(edadane)

table edadane [aw=peso] if hv103==1 & meses==1, c (m anemia) f(%9.3f) row

**sexo
table hv104 [aw=peso] if hv103==1 & meses==1, c (m anemia) f(%9.3f) row
***tipo de anemia
tab hc57 [aw=peso] if hv103==1 & meses==1
***tipo de anemia y quintiles de ingreso
tab hv270 hc57 [aw=peso] if hv103==1 & meses==1, row nofreq


**orden de nacido.
recode hc64 (1=1 "1") (2/3=2 "2-3") (4/5=3 "4-5") (6/13=4 "6+") (.=.), g(orden)
table orden [aw=peso] if hv103==1 & meses==1, c (m anemia) f(%9.3f) row

**tratamiento del agua
**embotellada
table hv237g [aw=peso] if hv103==1 & meses==1, c (m anemia) f(%9.3f) row
***completar


***quintil de riqueza
table hv270 [aw=peso] if hv103==1 & meses==1, c (m anemia) f(%9.3f) row

****anemia de 6 a 59
recode hc1 (6/59=1) (else=0), g(mese)
tab anemia [iw=peso] if hv103==1 & mese==1
***pestaña 10.14A
tab area anemia [iw=peso] if hv103==1 & mese==1, row nofreq
***10.14
table shregion [iw=peso] if hv103==1 & mese==1, c(m anemia) row f(%9.3f)

***programas sociales --> articulado nutricional
tab qh95 if hv103==1 & meses==1 & qhhome==1
table qh95 [aw=peso] if hv103==1 & meses==1, c(m anemia) row







******
*
*
*
****VIOLENCIA FAMILIAR

**violencia psicológica --> el INEI lo desagrega
*irse de la casa, etcc
recode d103d (0=0 "no") (1/3=1 "si"), g(amen1)
tab amen1 [iw=peso2]
*hacerle daño  -->> ver pestaña 12.2 cap_012
recode d103b (0=0 "no") (1/3=1 "si"), g(amen2)
tab amen2 [iw=peso2]
table area [aw=peso2], c(m amen2) row f(%9.3f)
table shregion [aw=peso2], c(m amen2) row f(%9.3f)
*humillaciones
recode d103a (0=0 "no") (1/3=1 "si"), g(humi)
tab humi [iw=peso2]
*celos
recode d101a (0 8=0 "no") (1=1 "si"), g(celos)
table shregion [aw=peso2], c(m celos) row f(%9.3f)
*acusa de ser infiel
recode d101b (0 8=0 "no") (1=1 "si"), g(infid)
table shregion [aw=peso2], c(m infid) row f(%9.3f)
*impide que visite amigas o familiares
recode d101c (0 8=0 "no") (1=1 "si"), g(impide)
replace impide=1 if d101d==1
table shregion [aw=peso2], c(m impide) row f(%9.3f)
*insiste en saber dónde va
recode d101e (0 8=0 "no") (1=1 "si"), g(dndes)
table shregion [aw=peso2], c(m dndes) row f(%9.3f)
*desconfia dinero
recode d101f (0 8=0 "no") (1=1 "si"), g(desdin)
table shregion [aw=peso2], c(m desdin) row f(%9.3f)
*algún tipo de control
recode d102 (0=0 "no") (1/6=1 "control"), g(control)
table shregion [aw=peso2], c(m contro) row f(%9.3f)
*Violencia psicológica
g violenpsi=(amen1==1 | amen2==1 | humi==1 | celos==1 | infid==1 | impide==1 | dndes==1 | desdin==1 |control==1 )
replace violenpsi=. if amen1==.
table shregion [iw=peso2], c(m violenpsi) row f(%9.3f)
*por departamentos
table dpto [aw=peso2], c(m violenpsi) row f(%9.3f)
table shregion, c(count violenpsi) row f(%9.3f) 
************COMPLETAR? no cuadra por decimales
*por edades
recode hv105 (15/19=1 "15-19") (20/24=2 "20-24") (25/29=3 "25-29") (30/34=4 "30-34") (35/39=5 "35-39") (40/44=6 "40-44") (45/49=7 "45-49"), g(edades)
table edades [aw=peso2] if hv105>=15, c(m violenpsi) row f(%9.3f)

*por estado civil
recode hv115 (1/2=1 "unida") (3/5 0=2 "no unido"), g(estciv)
table estciv [aw=peso2] , c(m violenpsi) row f(%9.3f)
*nivel de educación
fre v149
recode v149 (0=1 "sin educación") (1/2=2 "primaria") (3/4=3 "secundaria") (5=4 "superior"), g(nivedu)
table nivedu [aw=peso2] , c(m violenpsi) row f(%9.3f)
*quintil de riqueza
table hv270 [aw=peso2] , c(m violenpsi) row f(%9.3f)
*autoidentificación étnica
recode v131 ()
*lengua materna
fre v131
recode v131 (1/9=2 "nativa") (10=1 "castellano") (11/12=3 "extranjera"), g(lengua)
table lengua [aw=peso2] , c(m violenpsi) row f(%9.3f)

*
*
*
*
*
**


**violencia física --> desagrega --> pestaña 12.3 cap_012
***tanto sin ponderar como ponderado cuadran los totales
*empujo
recode d105a (0=0 "no") (1/3=1 "si"), g(empujo)
tab empujo [iw=peso2]
tab area empujo [iw=peso2], row freq

table area [iw=peso2], c(m empujo) row f(%9.3f)
*sin ponderar y en niveles
table area, c(count empujo) row f(%9.3f)
*
*
svyset hv001 [w=peso2], strata(hv022)
svy:proportion violenfis
**
table shregion [iw=peso2], c(m empujo) row f(%9.3f)
**sin ponderar y en niveles
table shregion, c(count empujo) row f(%9.3f)

*abofeteo
recode d105b (0=0 "no") (1/3=1 "si"), g(abofe)
table area [iw=peso2], c(m abofe) row f(%9.3f)
table shregion [iw=peso2], c(m abofe) row f(%9.3f)
*golpeó --> por decimales!!!
recode d105c (0=0 "no") (1/3=1 "si"), g(golp)
table shregion [iw=peso2], c(m golp) row f(%9.3f)
*pateó
recode d105d (0=0 "no") (1/3=1 "si"), g(pat)
table shregion [iw=peso2], c(m pat) row f(%9.3f)
*estrangulación
recode d105e (0=0 "no") (1/3=1 "si"), g(estr)
table shregion [iw=peso2], c(m estr) row f(%9.3f)
*atacó
recode d105g (0=0 "no") (1/3=1 "si"), g(atac)
table shregion [iw=peso2], c(m atac) row f(%9.3f)
*amenaza arm
recode d105f (0=0 "no") (1/3=1 "si"), g(amarm)
table shregion [iw=peso2], c(m amarm) row f(%9.3f)
***generando violencia física

g violenfis=(empujo==1 | abofe==1 | golp==1 | estr==1 | atac==1 | amarm==1 | pat==1)
replace violenfis=. if empujo==.
table shregion [iw=peso2], c(m violenfis) row f(%9.3f)

**violencia sexual
**obligó a tener relaciones
recode d105h (0=0 "no") (1/3=1 "si"), g(oblsex)
table shregion [iw=peso2], c(m oblsex) row f(%9.3f)
*obligó actos indebidos
recode d105i (0=0 "no") (1/3=1 "si"), g(oblact)
table shregion [iw=peso2], c(m oblact) row f(%9.3f)
***generando violencia sexual
g violensex= (oblsex==1 | oblact==1)
replace violensex=. if oblsex==.
table shregion [iw=peso2], c(m violensex) row f(%9.3f)

**VIOLENCIA FIS O SEX
g violfisosex=(violenfis==1 | violensex==1)
replace violfisosex=. if violenfis==. | violensex==.
table shregion [iw=peso2], c(m violfisosex) row f(%9.3f)

***CUALQUIER TIPO DE VIOLENCIA ALGUNA VEZ --> violencia en ppr
g violen=violfisosex==1 | violenpsi==1
replace violen=. if violfisosex==. 
table area [aw=peso2], c(m violen) row f(%9.3f)
