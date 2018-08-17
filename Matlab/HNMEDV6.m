function [best,E_F]= HNMEDV6(NE,NS)
% Se seleccionan los par�metros de expansi�n,
% contracci�n y reflexi�n. 
gamma=1.7;
beta=0.3;
alpha=2;
% Asignando la n para el problema actual.
n= get_problem_n();
% Asignando los l�mites de las variables.
bounds=get_problem_bound();
% Calculando el tama�o de la poblaci�n.
NP=(n+1)*NS;
X=zeros(NP,n+2);
% Generando y evaluando la poblaci�n.  
X=generate_border_simplex(NS);
% Inciando generador de n�meros aleatorios.
rng('shuffle','twister');
best=X(1,:);
E=NP;
XL=zeros(NS,n+2);
E_F=[];
m=NS+1;
% Comienza el ciclo hasta llegar al n�mero 
% m�ximo de evaluaciones
while E<NE
    k=1;
    w=1;
    % m={1,2,...,NS}
    if m>NS
       m=1;
    end
    % Se generan los factores 
    % de escala y crizamiento
    [F,CR]=generate_F_and_CR();
    while w<NP
        % NELDER MEAD SONBRE SIMPLEX SK
        % Seleccionar Sk de X
        Sk=X(w:(w+n),:);
        % Ordenea ascendentemente de acuerdo 
        % a las reglas de Deb
        Sk=sort_by_rules(Sk);
      % Seleccionar el mejor punto
        xl=Sk(1,:);
        % Seleccionar el segundo peor punto
        xg=Sk(n,:);
        % Seleccionar el peor punto
        xh=Sk(n+1,:);
        % Calcular el centroide
        xc= sum(Sk(1:n,:))/(n);
        %________Reflexi�n____________________
        xr=alpha*xc(1:n)-xh(1:n);
        xr=limit(xr,bounds);
        xr=evaluate_x_i(xr,n);
        xnew=xr;
        E=E+1;        
        if compare_by_rules(xr,xl)
        %_______Expansi�n_____________________
            xnew= (1+gamma)*xc(1:n)-gamma*xh(1:n);
        elseif ~compare_by_rules(xr,xh)
        %_______Contracci�n  hacia fuera______
            xnew= (1-beta)*xc(1:n)+beta*xh(1:n);
        elseif compare_by_rules(xg,xr) && compare_by_rules(xr,xh)
        %_______Contracci�n hacia dentro______
            xnew= (1+beta)*xc(1:n)-beta*xh(1:n);
        end
        xnew(1:n)=limit(xnew(1:n),bounds);
        xnew=evaluate_x_i(xnew(1:n),n);
        E=E+1;
        if compare_by_rules(xnew,xh)
            Sk(n+1,:)=xnew;
        else
        % Si ninguno de los operadores originales 
        % mejora a xnew se aplica el operador de V5
            [xr1,xr2,xr3]=generate_xr1_xr2_xr3(w,X);
            xnew=xr1(1:n)+F*(best(1:n)-xr1(1:n))+(1-F)*(xr2(1:n)-xr3(1:n));
            xnew=limit(xnew(1:n),bounds);
            xnew=evaluate_x_i(xnew,n);
            E=E+1;
            Sk(n+1,:)=xnew;
        end
        if compare_by_rules(xnew,xl)
            xl=xnew; 
        end 
        XL(k,:)=xl; 
        X(w:w+n,:)=Sk;
        if compare_by_rules(xnew,best)
            best=xnew;
        end
        % EVOLUCI�N DIFERENCIAL SE APLICA  A S(m)
        [xr1,xr2,xr3]=generate_xr1_xr2_xr3(w,X);
        parent=Sk(m,:);
        % Se selecciona un invidiuo aleatoriamente
        % de XL (los mejores puntosde  cada Simplex)
        rk=randi(NS);
        xlk=XL(rk,:);
        v=parent(1:n)+F*(xlk(1:n)-xr1(1:n))+(1-F)*(xr2(1:n)-xr3(1:n));
        v=limit(v,bounds);
        u=zeros();
        jrand=randi(n,1);
        for j=1:n
            randj=rand();
            if(randj<CR || jrand==j)
                u(j)=v(j);
            else
                u(j)=parent(j);
            end
        end
        u= evaluate_x_i(u,n);
        E=E+1;
        if compare_by_rules(u,parent)
            Sk(m,:)=u;
        end
       if compare_by_rules(u,xl)
            XL(k,:)=u;
        end
        if compare_by_rules(u,best)
            best=u;
        end
        X(w:w+n,:)=Sk;
        k=k+1;
        w=w+n+1;
        
    end
    % Se incrementa m por generaci�n 
    m=m+1;
    % Se almacena el valor de la F(x) de best y E para
    % Gr�ficas de convergencia
    [E_F]=uptdate_E_F(E,E_F,best);    
end
end


