%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Universidade Federal do Piauí                       %
% Campus Ministro Petronio Portela                    %
% Copyright 2022 -José Borges do Carmo Neto-          %
% @author José Borges do Carmo Neto                   %
% @email jose.borges90@hotmail.com                    %
%  -- Level control of a conical tank using Interval  %
%  Type-2 Fuzzy Logic PID controllers for the Phase   %
%  and Gain Margins of the System                     % 
%  nas margens de fase e de ganho                     %
%  -- Version: 1.0  - 20/02/2022                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Algoritmo genetico:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Definições do AG
%Parametro de reprodução:
   prob_mutation = 0.1;%rand(1);
   prob_crossover = 0.8;%rand(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CODIFICAÇÃO:Real
geracoes = 50;
%%
%PASSO 1: 
    %INICIAR A POPULAÇÃO:
        populacao_size = 256; %defino o tamanho da população
        populacao = {};% crio a cell que sera a minha população
        N_mais_aptos = 16; %Numero dos individuos mais aptos que serão salvos para a proxima geração.
        gene_size = 12;
        for j=1:populacao_size %A criação da população 
           
           genetic_code = [];
           score = 0;
            
           for i=1:gene_size
                genetic_code = [genetic_code ,abs(-0.5+rand);];
            
            populacao{j,1} = genetic_code;
            populacao{j,2} = score;
           end
        end
        
        thebest = populacao(j,:);
memoria_thebest(1,:)= thebest;

%% PASSO 2:%Criar o loop de evolução:
convergencia = 0;
geracao = 1;
while convergencia == 0,
    
     % Avaliação dos individuos da população:
    
    for h=1:populacao_size %Etapa de avaliação da população para o AG   
        script_CN_T2_PID_FG_CONICAL_TANK; %Chama o script com o controlador implementado
        
        J= objfunc(erro,tempo,'ITAE');
        populacao{h,2} = (1/J)*10^4;
    end
    
  % Retorna um vetor com os valores dos cromossomos do melhores e outro com a cell contendo os melhores e seu score
    [mais_aptos teste] =  selecao_natural(populacao,N_mais_aptos);
    
  %Testar e salvar do melhor individuo já encotrado:
                v =  teste(1,:);
                if thebest{1,2} < v{1,2}
                    thebest = teste(1,:);
                end
                memoria_thebest(geracao,:) = thebest;
 %% PASSO 3:
    %Seleção, Reprodução e Mutação:
                
                filhos = reproducao(populacao,mais_aptos,populacao_size,prob_crossover);%Reprodução dos individuos mais aptos
                populacao = mutacao(populacao,prob_mutation);% Realiza a mutação sobre individuos da população
                resto = escolher_resto(populacao,N_mais_aptos,populacao_size); %escolhe os outros valores para a proxima população
                clear populacao; %Limpa populacao
                populacao = [teste;filhos;resto];%cria a proxima população que tera todos os elementos filhos criados com score = 0,
                %portanto a população salva no final da execução do
                %algoritmo possui os primeiros valores como os melhores,
                %seguido de valores com score 0 e seguidos de valores
                %aleatoriso escolhidos da população anterior.
 
 %% PASSO 4: 
 %Teste de parada do algoritmo:
                    if  (isequal(populacao{:,2})| geracao == geracoes), 
                            convergencia = 1;
                            break;
                    end
  geracao = geracao +1                  
end

gene = thebest{1,1}
plot_pertinencias_T2
figure;plot((1./[memoria_thebest{:,2}]));