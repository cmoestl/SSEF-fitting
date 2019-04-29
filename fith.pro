;+
;
; Name:       fith
; 
; Purpose:    function to fit HI elongation tracks using Lugaz formula
; 
; Parameters: X
;
; Keywords:  	-
;   	    	
;    	    	
; Called by fitall_sse.pro
;
;                  
; History:    May 2010/ update Feb 2011/March 2012
; 
; Author:     Christian Moestl 
;             Space Research Institute, Austrian Academy of Sciences
;             SSL UC Berkeley
;-

FUNCTION fith, X

common myfit2,xueber2,yueber2, dst2, scnameueber2

degtorad=!dpi/180;

phi=X[0];  % constant angle beta measured FROM OBSERVER, positive = solar west
v=X[1];  % constant speed
t=xueber2-X[2]; difference to launch time t0, which is the result to be written in X[2]
       
;because of the acos the angle phi has to be positive
if scnameueber2 eq 'A' then phi=-phi;


;Mšstl et al. 2011 ApJ, Equations A6 and A3
a=((2*dst2)/(v*t))-cos(phi)
b=sin(phi)
fit=-acos( (-b+a*sqrt(a^2+b^2-1))/(a^2+b^2)      ) /degtorad   
       
sizey=size(yueber2); how many data points are there?

residue=double(0); define the residue variable

for i=0,sizey(1)-1 do begin
   if finite(fit(i)) eq 0 then fit(i)=0  ;if NaNs make the residue very high  (do this by  setting values to zero)
     residue=residue+( abs(yueber2(i))-abs(fit(i)) )^2; squared difference between observation and fit for each datapoint
endfor

return, residue

END
