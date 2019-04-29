;+
;
; Name:       fitj
; 
; Purpose:    function to fit HI elongation tracks using Sheeleys formula
; 
; Parameters: X
;
; Keywords:  	-
;   	    	
;    	    	
; Called by fitelongation.pro
;
;                  
; History:    June 2009/update March 2012
; 
; Author:     Christian Moestl 
;             Space Research Institute, Austrian Academy of Sciences
;             SSL UC Berkeley
;-

FUNCTION fitj, X

common myfit,xueber,yueber, dst

degtorad=!dpi/180;

;after Sheeley 2008 ApJ
delta=90*degtorad-X[0]; delta wird v. Plane of Sky weg gemessen
rho=X[1]*(xueber-X[2])/dst;

fit=atan(rho*cos(delta)/(1-rho*sin(delta)))/degtorad

sizey=size(yueber); how many data points
residue=double(0); define residue variable
for i=0,sizey(1)-1 do begin
  ;sum up squared difference between observations and fit for each datapoint
  residue=residue+( abs(yueber(i))-abs(fit(i)) )^2;
 endfor
return, residue

END
