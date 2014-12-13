%en pruebas
% hacer una funcion para adsr a saco, otra para los adsr de armonicos que
% saca este archivo, otro para salcar un array con frecuencias de
% armonicos...

%bien, la idea es usar una ventana blackman con pocos ciclos para tener el
%espectro lo mas suave posible, de ahi se sacarú}n las frecuencias
%fácilmente con una funcion de máximos locales, con esas posiciones de los
%máximos y cierto margen de incertidumbre se pueden "enventanar" las deltas
%de los armónicos en un espectro con informaciones de amplitud más fiables
%que 4 ciclos con blackman. Tambien habria que ver todas las posibles
%deficiencias del sistema de detección de frecuencias, de las q ahora mismo
%se me ocurren: 
%1)aparicion de máximos antes de f0 ( f0 con correlacion y au)
%2)máximos falsos donde hay ruido (solucion: q la frecuencia sea armónica
%admitiendo cierta desviación)
%3) máximos espurio entre dos armónicos ((esto se puede arreglar dando la
%condicion de q sea el máximo de la miniventana))

clear;
close all;
clc;

[source fs]=wavread('Sounds/la4guit.wav');
source=source(:,1);
%fund=fundamental(source,fs);  %es una aproximacion, posiciones(1) es otra.
fund=880;
T=floor(fs/fund); %1 ciclo

%%%obtencion de las frecuencias de armónicos con blackman%%%%%%%%%%
    [asdws, start]=max(source); %empiezo en un punto poco conflictivo
    % 4 ciclos 
    nota_4_ciclos=abs( fft(blackman(4*T).*source(start:start+4*T-1),fs) );
    nota_4_ciclos=nota_4_ciclos(1:fs/2);
    nivel=20*log10(nota_4_ciclos);

    [maximos posiciones]=lmax(nivel);

    asdf=ones(length(nivel),1);
    asdf(posiciones)=maximos;
    asdf(asdf==1)=inf;
    

    %primera especie de falsos armonicos: subarmonicos
    %precaucion! no siempre existe, 
    
    %vale, al parecer a veces hay mas de uno
    if(posiciones(1)<fund*0.8)
        asdf(posiciones(1))=inf;
        posiciones=posiciones(2:end);
        maximos=maximos(2:end);
    end

    
    % habria que implementar dos niveles de desviación armónica, ya que puede fallar
    %comprobando solo 1. la idea es que con nota40 si hay un armonico
    %con desviacion 200 y el siguiente a 600, con un solo nivel ambos
    %serú}n descartados, mientras que con 2 el 2º se salvarú}

    %segunda especie: inarmonicos
     diferencias1=zeros(1,length(posiciones)-1);
     diferencias2=zeros(1,length(posiciones)-1);
     umbral=0.25;
    for i=2:length(diferencias1)
        diferencias1(i)=abs(posiciones(i)-posiciones(i-1));
        diferencias2(i)=abs(posiciones(i+1)-posiciones(i-1));
    end
        diferencias1(1)=fund;
        diferencias2(1)=2*fund;
        mapa=find( (abs(diferencias2-2*fund)>1/2*fund) .* (abs(diferencias1-fund)>1/4*fund));
        asdf(posiciones(mapa))=inf;

        %cambiar de posicion todo este bloque
        %para ver la evolucion del algoritmo
        plot(1:fs/2,50+nivel);
        title('nota ventana blackman');
        grid;hold;
        plot(50+asdf,'.r');

        %reciclaje (por ahorrar ram)
        %clear nota;
        clear asdf;
        clear nivel;
        clear mapa;
        
        
        
        
%%%%%%pruebas con 200 ventanas %%%
%con 300 podrú} funcionar bien, sigue habiendo mas de 4 ciclos por ventana
%en el peor de los casos y 'existe' attack en adsr
vent=200;
solapamiento=0.5;
spw=floor(2*length(source)/(vent+2));
vent1=overlapWindow(source,spw,solapamiento);
for i=1:vent
    vent1(:,i)=vent1(:,i).*blackman(spw);
end

s_fourier=abs(fft(vent1,fs));
s_fourier=s_fourier(1:end/2,:);
plot(s_fourier);
      
a=[];
ADSR=zeros(vent,length(posiciones));

for i=1:length(posiciones)
    for j=1:vent
        if(i==length(posiciones))
            a=s_fourier((posiciones(i)-round(0.5*fund)):(posiciones(i:end)) ,j);
        else
            a=s_fourier(abs((posiciones(i))-round(0.5*fund)):(posiciones(i)+round(0.5*fund)) ,j);
        end
        ADSR(j,i)=max(a);
    end
end

figure;
malla=ADSR(1:end,:)./max(max(ADSR));

%%%
malla(malla<=0.004)=inf;
%%%

mesh(malla);

