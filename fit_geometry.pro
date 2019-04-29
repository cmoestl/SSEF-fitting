;+
;
; Name:       fit_geometry.pro
; 
; Purpose:    visualizes solar transient directions obtained with fitting methods
;
; Parameters:  Angles to Earth obtained with FP, HM, SSE, SSE half-width, and observation date
;
; Keywords:  apex   - for setting the distance of the apex of the directions and circles in AU
;    	    	               default value=0.9
;
; Calling sequence: fit_geometry, earthangle_fixed_phi, earthangle_harmonic_mean, $
;                      earthangle_sse, sse_half_width, observation_date       
;
; Example: fit_geometry, 10,-10, 0, 50, '8-March-2012'        	
; 
; Side effects: calls SPICE to get STEREO and Earth positions for given observation_date 
;                  
; History:    written 31 March 2012
;
; Author:     Christian Moestl, SSL Berkeley and University of Graz, Austria
;             
;-



pro fit_geometry, earthangle, earthangleh, earthangles, lambda, date, apex=apex, file_in=file_in

;check if window 2 is open, if not create new one
Device, Window_State=theseWindows
if theseWindows(2) eq 0 then begin 
 window, 2, xsize=600,ysize=600, retain=2, xpos=600, ypos=500
endif
wshow, 2
wset,2
!p.background = 255
!p.color = 0

degtorad=!dpi/180
radtodeg=180/!dpi

pos_sta=get_stereo_lonlat(date, 'A', system='HEE')
pos_stb=get_stereo_lonlat(date, 'B', system='HEE')
pos_earth=get_stereo_lonlat(date, 'Earth', system='HEE')

AUkm=149597870.700 ;AU in km

;STEREO in HEE
stereoa_angle=pos_sta(1)*radtodeg;
stereoa_dist=pos_sta(0)/AUkm;;

stereob_angle=pos_stb(1)*radtodeg;
stereob_dist=pos_stb(0)/AUkm;
;Earth distance in AU
earth_dist=pos_earth/AUkm
;---------------------------------

;scaling 1 AU to normal coordinates
AU=0.4;
;Sun position in normal coordinates
sun=[0.5,0.6]
;Sun position in normal coordinates
earth=[0.5,sun(1)-earth_dist*AU]


stereoa=[sun(0)+sin(stereoa_angle*degtorad)*stereoa_dist*AU,sun(1)-cos(stereoa_angle*degtorad)*stereoa_dist*AU]
stereob=[sun(0)+sin(stereob_angle*degtorad)*stereob_dist*AU,sun(1)-cos(stereob_angle*degtorad)*stereob_dist*AU]

;______________________________________________________________________
;PLOT to window

;make background white
POLYFILL, [0,1,1,0],[0,0,1,1], /NORMAL, color=255

;Spacecraft positions
PLOTS, [sun(0), earth(0)], [sun(1), earth(1)],  $
	color=0, linestyle=1, /NORMAL, thick=2
PLOTS, earth(0), earth(1), color=0, psym=4, /NORMAL, thick=2
PLOTS, [sun(0), stereoa(0)], [sun(1), stereoa(1)],  $
	color=0, linestyle=1, /NORMAL, thick=2
PLOTS, stereoa(0), stereoa(1), color=0, psym=7, /NORMAL, thick=2
PLOTS, [sun(0), stereob(0)], [sun(1), stereob(1)],  $
	color=0, linestyle=1, /NORMAL, thick=2
PLOTS, stereob(0), stereob(1), color=0, psym=5, /NORMAL, thick=2

XYOUTS, sun(0),sun(1), 'Sun', /NORMAL, charsize=2, charthick=2,alignment=0.5
XYOUTS, earth(0),earth(1)-0.04, 'Earth', /NORMAL, charsize=2, charthick=2,alignment=0.5
XYOUTS, stereoa(0)+0.05,stereoa(1), 'A', /NORMAL, charsize=2, charthick=2,alignment=0.5
XYOUTS, stereob(0)-0.05,stereob(1), 'B', /NORMAL, charsize=2, charthick=2,alignment=0.5


;this controls the length of the directions
IF KEYWORD_SET(apex) THEN BEGIN
  dirAU=apex
ENDIF ELSE BEGIN
 dirAU=0.9
ENDELSE


;FP direction
fpdir=[sin(earthangle*degtorad),cos(earthangle*degtorad)]*AU*dirAU
PLOTS, [sun(0), sun(0)+fpdir(0)], [sun(1), sun(1)-fpdir(1)],  $
	color=0, linestyle=3, /NORMAL, thick=2

;HM directions
hmdir=[sin(earthangleh*degtorad),cos(earthangleh*degtorad)]*AU*dirAU
PLOTS, [sun(0), sun(0)+hmdir(0)], [sun(1), sun(1)-hmdir(1)],  $
	color=0, linestyle=4, /NORMAL, thick=2
;HM circle
points = (2 * !PI / 99.0) * FINDGEN(100)
xc = sun(0)+hmdir(0)/2 + (AU*dirAU/2) * COS(points )
yc = sun(1)-hmdir(1)/2 + (AU*dirAU/2) * SIN(points )
PLOTS, xc,yc, /normal, linestyle=4, thick=2

;SSE directions
ssdir=[sin((earthangles)*degtorad),cos((earthangles)*degtorad)]*AU*dirAU
PLOTS, [sun(0), sun(0)+ssdir(0)], [sun(1), sun(1)-ssdir(1)],  $
	color=0, linestyle=0, /NORMAL, thick=2

ssdirplus=[sin((earthangles+lambda)*degtorad),cos((earthangles+lambda)*degtorad)]*AU*dirAU
PLOTS, [sun(0), sun(0)+ssdirplus(0)], [sun(1), sun(1)-ssdirplus(1)],  $
	color=0, linestyle=0, /NORMAL, thick=2

ssdirminus=[sin((earthangles-lambda)*degtorad),cos((earthangles-lambda)*degtorad)]*AU*dirAU
PLOTS, [sun(0), sun(0)+ssdirminus(0)], [sun(1), sun(1)-ssdirminus(1)],  $
	color=0, linestyle=0, /NORMAL, thick=2

;SSE circle at 1 AU
xc = sun(0)+ssdir(0)/(1+sin(lambda*degtorad)) + (AU*dirAU*sin(lambda*degtorad)/(1+sin(lambda*degtorad))) * COS(points )
yc = sun(1)-ssdir(1)/(1+sin(lambda*degtorad)) + (AU*dirAU*sin(lambda*degtorad)/(1+sin(lambda*degtorad))) * SIN(points )
PLOTS, xc,yc, /normal, linestyle=0, thick=2


;LEGEND
XYOUTS, 0.15,0.05, 'FP', /NORMAL, charsize=2, charthick=2,alignment=0.5
PLOTS, [0.19,0.24],[0.06,0.06], /normal, linestyle=3, thick=2
XYOUTS, 0.3,0.05, 'HM', /NORMAL, charsize=2, charthick=2,alignment=0.5
PLOTS, [0.34,0.39],[0.06,0.06], /normal, linestyle=4, thick=2
XYOUTS, 0.7,0.05, 'SSE', /NORMAL, charsize=2, charthick=2,alignment=0.5
PLOTS, [0.74,0.79],[0.06,0.06], /normal, linestyle=0, thick=2


;make jpeg output and title with average date of HI observation
IF KEYWORD_SET(file_in) THEN BEGIN
 filejpg='fit_'+file_in+'_geometry.jpg'
 ;title
 XYOUTS, sun(0),0.95, ['Ecliptic plane view of event: '+strmid(date,0,10)], /NORMAL, $
	charsize=2, charthick=2, alignment=0.5
ENDIF ELSE BEGIN
 filejpg='fit_'+date+'_geometry.jpg'
 ;title
 XYOUTS, sun(0),0.95, ['Ecliptic plane view of event: '+date], /NORMAL, $
	charsize=2, charthick=2, alignment=0.5
ENDELSE
x2jpeg, filejpg













;_______________________________________________________
;PLOT TO EPS


set_plot,'PS'

IF KEYWORD_SET(file_in) THEN BEGIN
 filenameeps='fit_'+file_in+'_geometry.eps'
ENDIF ELSE BEGIN
 filenameeps='fit_'+date+'_geometry.eps'
ENDELSE

thickness=5
charthickness=6
device, /encapsulated, filename=filenameeps, xsize=20, ysize=20, /color, bits_per_pixel=8 

;make background white
POLYFILL, [0,1,1,0],[0,0,1,1], /NORMAL, color=255


;make title with average date of HI observation
IF KEYWORD_SET(file_in) THEN BEGIN
 ;title
 XYOUTS, sun(0),0.95, ['Ecliptic plane view of event: '+strmid(date,0,10)], /NORMAL, $
	charsize=2, charthick=charthickness, alignment=0.5
ENDIF ELSE BEGIN
 ;title
 XYOUTS, sun(0),0.95, ['Ecliptic plane view of event: '+date], /NORMAL, $
	charsize=2, charthick=charthickness, alignment=0.5
ENDELSE


;Spacecraft positions
PLOTS, [sun(0), earth(0)], [sun(1), earth(1)],  $
	color=0, linestyle=1, /NORMAL, thick=thickness
PLOTS, earth(0), earth(1), color=0, psym=4, /NORMAL, thick=thickness
PLOTS, [sun(0), stereoa(0)], [sun(1), stereoa(1)],  $
	color=0, linestyle=1, /NORMAL, thick=thickness
PLOTS, stereoa(0), stereoa(1), color=0, psym=7, /NORMAL, thick=thickness
PLOTS, [sun(0), stereob(0)], [sun(1), stereob(1)],  $
	color=0, linestyle=1, /NORMAL, thick=thickness
PLOTS, stereob(0), stereob(1), color=0, psym=5, /NORMAL, thick=thickness

XYOUTS, sun(0),sun(1), 'Sun', /NORMAL, charsize=2, $
	charthick=charthickness, alignment=0.5
XYOUTS, earth(0),earth(1)-0.04, 'Earth', /NORMAL, charsize=2, $
	charthick=charthickness,alignment=0.5
XYOUTS, stereoa(0)+0.05,stereoa(1), 'A', /NORMAL, charsize=2, $
	charthick=charthickness, alignment=0.5
XYOUTS, stereob(0)-0.05,stereob(1), 'B', /NORMAL, charsize=2, $ 
        charthick=charthickness,alignment=0.5

;FP direction
PLOTS, [sun(0), sun(0)+fpdir(0)], [sun(1), sun(1)-fpdir(1)],  $
	color=0, linestyle=3, /NORMAL, thick=thickness
;HM directions
PLOTS, [sun(0), sun(0)+hmdir(0)], [sun(1), sun(1)-hmdir(1)],  $
	color=0, linestyle=4, /NORMAL, thick=thickness
;HM circle
points = (2 * !PI / 99.0) * FINDGEN(100)
xc = sun(0)+hmdir(0)/2 + (AU*dirAU/2) * COS(points )
yc = sun(1)-hmdir(1)/2 + (AU*dirAU/2) * SIN(points )
PLOTS, xc,yc, /normal, linestyle=4, thick=thickness

;SSE directions
PLOTS, [sun(0), sun(0)+ssdir(0)], [sun(1), sun(1)-ssdir(1)],  $
	color=0, linestyle=0, /NORMAL, thick=thickness
PLOTS, [sun(0), sun(0)+ssdirplus(0)], [sun(1), sun(1)-ssdirplus(1)],  $
	color=0, linestyle=0, /NORMAL, thick=thickness
PLOTS, [sun(0), sun(0)+ssdirminus(0)], [sun(1), sun(1)-ssdirminus(1)],  $
	color=0, linestyle=0, /NORMAL, thick=thickness

;SSE circle at 1 AU
xc = sun(0)+ssdir(0)/(1+sin(lambda*degtorad)) + (AU*dirAU*sin(lambda*degtorad)/(1+sin(lambda*degtorad))) * COS(points )
yc = sun(1)-ssdir(1)/(1+sin(lambda*degtorad)) + (AU*dirAU*sin(lambda*degtorad)/(1+sin(lambda*degtorad))) * SIN(points )
PLOTS, xc,yc, /normal, linestyle=0, thick=thickness

;LEGEND
XYOUTS, 0.15,0.05, 'FP', /NORMAL, charsize=2, $
	 charthick=charthickness,alignment=0.5
PLOTS, [0.19,0.24],[0.06,0.06], /normal, linestyle=3, thick=thickness
XYOUTS, 0.3,0.05, 'HM', /NORMAL, charsize=2, $
	 charthick=charthickness,alignment=0.5
PLOTS, [0.34,0.39],[0.06,0.06], /normal, linestyle=4, thick=thickness
XYOUTS, 0.7,0.05, 'SSE', /NORMAL, charsize=2, $
	 charthick=charthickness,alignment=0.5
PLOTS, [0.74,0.79],[0.06,0.06], /normal, linestyle=0, thick=thickness

device, /close      

SET_PLOT, 'X'


;TO DO-----------------------------


END
