     h nomain PGMINFO(*PCML:*MODULE)

     d ConvertTemp     pr
     d tempIn                        10    const
     d tempOut                       10

     p ConvertTemp     b                   export
     d ConvertTemp     pi
     d tempIn                        10    const
     d tempOut                       10

     d tempI           s              8P 2
     d tempO           s              8P 2
     d value           S             50A
      /free
       value = %STR(%ADDR(tempIn));
       tempI=%DEC(value:7:2);
       tempO = (5/9)*(tempI * 32);
       value = %CHAR(tempO);
       tempOut = value;
       %STR(%ADDR(tempOut):10)=tempOut;
      /end-free
     p ConvertTemp     e

