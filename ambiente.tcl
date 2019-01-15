#Instancia o NS
set ns [new Simulator]

#Uso de roteamento dinamico (para queda de enlace)
$ns rtproto DV

#Define as cores para os fluxos de dados
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Yellow

#Cria o arquivo do Netwaor Animator
set nf [open animacao.nam w]
$ns namtrace-all $nf

#Cria o arquivo de trace para geração de graficos
set nt [open wtrace.tr w]
$ns trace-all $nt

#Procedimento de Encerramento da simulacao
proc encerrar {} {
        global ns nf nt
        $ns flush-trace
	#Fecha os arquivos
        close $nf 
        close $nt
	#Executa o nam a partir do arquivo gerado
        exec nam animacao.nam &
        exit 0
}

#Cria os roteadores 
set rt_host1 [$ns node];
set rt_host3 [$ns node]; 
set rt_host2 [$ns node]; 
set rt_ceunes [$ns node];


#Cria legendas no NAM
$ns at 0.0 "$rt_host1 label rt_host1"
$ns at 0.0 "$rt_host3 label rt_host3"
$ns at 0.0 "$rt_host2 label rt_host2"
$ns at 0.0 "$rt_ceunes label rt_ceunes"


#Cria o enlace entre os nos
$ns duplex-link $rt_host1 $rt_host2 10Mb 100ms DropTail
$ns duplex-link $rt_host3  $rt_host2 10Mb 100ms DropTail
$ns duplex-link $rt_host2 $rt_ceunes 10Mb 200ms DropTail

# ------------ Procedures de Trafego TCP -----------------------------------
proc cria_conexao_cbr { origem destino inicio fim taxa tamanho_pacote classe tempomudataxa novataxa } {
   global ns
   set tcp0 [new Agent/TCP]
   set src [new Application/Traffic/CBR]
   $tcp0 set packetSize_ $tamanho_pacote
   $tcp0 set class_ $classe
   $src set rate_ $taxa
   set sink0 [new Agent/TCPSink]
   $ns attach-agent $origem $tcp0
   $src attach-agent $tcp0
   $ns attach-agent $destino $sink0
   $ns connect $tcp0 $sink0
   $ns at $inicio "$src start"
   if {$tempomudataxa != 0} {    
      set comando "\$ns at $tempomudataxa \"\$src set rate_ $novataxa\""
      eval $comando
   }
   $ns at $fim "$src stop"
   return $tcp0
}

# Trafego ----------------------------------
# Parâmetros = origem, destino, tempo inicio, tempo fim, taxa, tamanho do pacote, sequencial, instante de mudança de taxa, nova taxa)
set cbr_Video1 [cria_conexao_cbr $rt_host1 $rt_ceunes 1 7200 153Kb 1250 1 0 0M]
set cbr_Video2 [cria_conexao_cbr $rt_host3  $rt_ceunes 1 7200 180Kb 910 1 0 0M]
set cbr_Video3 [cria_conexao_cbr $rt_host2  $rt_ceunes 1 7200 148Kb 943 1 0 0M]

#Chama o procedimento de encerramento 
$ns at 30.0 "encerrar"

#Executa a simulacao
$ns run
