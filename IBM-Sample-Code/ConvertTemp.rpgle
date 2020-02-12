**free
ctl-opt nomain PGMINFO(*PCML:*MODULE);

dcl-pr ConvertTemp;
  tempIn int(10) const;
  tempOut int(10);
end-pr;

dcl-proc ConvertTemp export;
  Dcl-pi *N;
    tempIn int(10) const;
    tempOut int(10);
  End-pi;

  dcl-s tempI packed(8 : 2);
  dcl-s tempO packed(8 : 2);
  dcl-s value char(50);

  value = %STR(%ADDR(tempIn));
  tempI=%DEC(value:7:2);
  tempO = (5/9)*(tempI * 32);
  value = %CHAR(tempO);
  tempOut = value;
  %STR(%ADDR(tempOut):10)=tempOut;
end-proc;


