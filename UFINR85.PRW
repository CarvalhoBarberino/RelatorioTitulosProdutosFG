#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"

#DEFINE NOME_DO_FONTE "UFINR85.PRW"
//#DEFINE MOSTRA_QUERY
//#DEFINE SEM_PARAMETROS // Usado para testes durante o desenvolvimento

/*/{Protheus.doc} FINR85
	Funcao que gera relatorios de titulos com dados do faturamento
	@type user function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
/*/
user function FINR85()
	local oReport
	local aPergs		:= {}
	local areaPreserv	:= getArea()
	local nI

	private oSecE1		:= Nil
	private oSecE5		:= Nil
	private oSecD2		:= Nil
	private cAliasE1	:= "UFINR85E1"
	private cAliasE5	:= "UFINR85E5"
	private cAliasD2	:= "UFINR85D2"
	private cAliasTot	:= "UFINR85TOT"
	private cFilSN		:= "2"
	private cSitSN		:= "2"
	private cCliSN		:= "2"
	private cProdSN		:= "1"
	private cMovSN		:= "1"
	private cJurPadSN	:= "1"
	private nJur		:= 0
	private cJur		:= ""
	private nMulta		:= 0
	private cAouD		:= "1"
	private cMulta		:= ""
	private cZeraJurSN	:= "2"
	private aAgrop		:= {"2", "0", "0", "0", "0"}
	private cTipPer		:= "1"
	private nPerAD		:= 0
	private cPrdG		:= "1"
	private cTipHier	:= "3"
	private aFil		:= {}
	private cFil		:= ""
	private aSitu		:= {}
	private cSit		:= ""
	private cCli		:= ""
	private cSafra		:= "0"
	private cCultura	:= "     "

	private cDtVenc0	:= Ctod(Space(8))
	private cDtVenc1	:= Ctod(Space(8))
	private cDtEmis0	:= Ctod(Space(8))
	private cDtEmis1	:= Ctod(Space(8))
	#IFDEF MOSTRA_QUERY
		private cMostraE5	:= MsgYesNo("Mostrar Query E5", NOME_DO_FONTE)
		private cMostraD2	:= MsgYesNo("Mostrar Query D2", NOME_DO_FONTE)
	#ENDIF
	private aBreak		:= {}

	aAdd(aPergs, {1, "Vencimento de",								cDtVenc0,		"",				"",		"",	"",		50,	.T.})
	aAdd(aPergs, {1, "Vencimento até",								cDtVenc1,		"",				"",		"",	"",		50,	.T.})
	aAdd(aPergs, {1, "Emissao de",									cDtEmis0,		"",				"",		"",	"",		50,	.T.})
	aAdd(aPergs, {1, "Emissao até",									cDtEmis1,		"",				"",		"",	"",		50,	.T.})
	aadd(aPergs, {2, "Selecionar filiais especificas",				cFilSN,			{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Selecionar Situacoes especificas",			cSitSN,			{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Selecionar clientes especificos",				cCliSN,			{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Zerar taxas e multas",						cZeraJurSN,		{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Taxas de juros padrão",						cJurPadSN,		{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {1, "TxJurosDiário",								nJur,			"@E 99.999999",	".T.",	"",	".T.",	80,	.F.})
	aadd(aPergs, {1, "Multa",										nMulta,			"@E 99,999.99",	".T.",	"",	".T.",	80,	.F.})
	aadd(aPergs, {2, "Antecipação/Desconto",						cAouD,			{"1=Não aplicar", "2=Antecipação", "3=Desconto"},	80, ".T.", .F.})
	aadd(aPergs, {1, "Percentual Antecipação/Desconto",				nPerAD,			"@E 999.99",	".T.",	"",	".T.",	80,	.F.})
	aadd(aPergs, {2, "Grupo de produto",							cPrdG,		;
		{;
		"1=Todos", ;
		"2=CRF", ;
		"3=Specialties", ;
		"4=Biologics/BioControl" ;
		},					120, ".T.", .F.})
	aadd(aPergs, {2, "Safra",										cSafra,		{"0=Não filtrar", "1=Verao", "2=2ª  Safra", "3=Campanha  Verao", "4=Campanha  2ª  Safra"},					50, ".T.", .F.})
	aAdd(aPergs, {1, "Cultura",										cCultura,		"",				"",		"NP3",	"",		50,	.F.}) // NP3 - Culturas

	if !ParamBox(aPergs, "Parametros de filtro") // https://terminaldeinformacao.com/knowledgebase/parambox/ https://www.blacktdn.com.br/2012/05/para-quem-precisar-desenvolver-uma.html https://logostechnology.zendesk.com/hc/pt-br/articles/360048936174-ADVPL-Tipos-e-par%C3%A2metros-da-fun%C3%A7%C3%A3o-ParamBox-em-ADVPL
		msgAlert("Os parametros não foram carregados", NOME_DO_FONTE)
		return
	else
		cDtVenc0	:= dToS(MV_PAR01)
		cDtVenc1	:= dToS(MV_PAR02)
		cDtEmis0	:= dToS(MV_PAR03)
		cDtEmis1	:= dToS(MV_PAR04)
		cFilSN		:= MV_PAR05
		cSitSN		:= MV_PAR06
		cCliSN		:= MV_PAR07
		cZeraJurSN	:= MV_PAR08
		cJurPadSN	:= MV_PAR09
		nJur		:= MV_PAR10
		nMulta		:= MV_PAR11
		cAouD		:= MV_PAR12
		nPerAD		:= MV_PAR13
		cPrdG		:= MV_PAR14
		cSafra		:= MV_PAR15
		cCultura	:= MV_PAR16
	EndIf

	cFil := ""
	if cFilSN == "1" // Seleciona filiais
		aFil := FwListBranches(.T., .T., .T., {'FLAG', 'SM0_CODFIL', 'SM0_NOMRED', 'SM0_CGC', 'SM0_INSC', 'SM0_INSCM'}) // https://tdn.totvs.com/display/public/framework/FwListBranches https://tdn.totvs.com/display/framework/FwListBranches https://tdn.totvs.com/pages/viewpage.action?pageId=427052751
		if len(aFil) > 0
			for nI := 1 to len(aFil)
				if aFil[nI][1]
					cFil += aFil[nI][2] + ";"
				endIf
			next
			cFil := subString(cFil, 1, len(cFil) - 1)
			cFil := FormatIN(cFil,";")
		else
			msgAlert("As filiais não foram carregadas. Não ha filtro de filiais", NOME_DO_FONTE)
		endIf
	endif

	if cSitSN == "1" // Seleciona situacoes
		if F_Opcoes(;
				@aSitu,;	//uVarRet
			"Filtro de tipos de situacoes",;	//cTitulo
			{"0-CARTEIRA", "1-SIMPLES", "2-DESCONTADA", "3-CAUCIONADA", "4-VINCULADA", "5-COM ADVOGADO", "6-JUDICIAL", "7-CAUÇÃO DESCONTADA", "F-CARTEIRA PROTESTO", "G-CARTEIRA ACORDO", "H-CARTÓRIO", "I-CARTEIRA CAIXA LOJA", "J-CARTEIRA CAIXA GERAL", "K-PIX", "L-PDD", "M-PCLD", "N-CHEQUES DEVOLVIDOS", "O-TESTE"},;		//aOpcoes
			"01234567FGHIJKLMNO",;		//cOpcoes
			12,;		//nLin1
			49,;		//nCol1
			.F.,;		//l1Elem
			1,;			//nTam
			999,;		//nElemRet
			.T.,;		//lMultSelect
			.F.,;		//lComboBox
			Nil,;		//cCampo
			.F.,;		//lNotOrdena
			.F.,;		//lNotPesq
			.T.,;		//lForceRe
			Nil;		//cF3
			)			// https://terminaldeinformacao.com/2024/02/27/abrindo-uma-tela-para-marcacao-de-registros-com-a-f_opcoes-maratona-advpl-e-tl-261/
			if len(aSitu) > 0
				for nI := 1 to len(aSitu)
					cSit += aSitu[nI] + ";"
				next
				cSit := substring(cSit, 1, len(cSit) - 1)
				cSit := FormatIN(cSit,";")
			endIf
		else
			msgAlert("Os parametros situacoes não foram carregados. Não há filtro para situações", NOME_DO_FONTE)
		endIf
	endIf

	cCli := ""
	if cCliSN == "1" // Seleciona Clientes
		if !U_FGSelCli(@cCli)
			msgAlert("Os clientes não foram carregados. Não há filtro para clientes", NOME_DO_FONTE)
			cCli := ""
		endIf
	endif

	aPergs := {}
	aadd(aPergs, {2, "Imprime Produtos ao final de cada título",	cProdSN,		{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Mostra informacoes de baixa",					cMovSN,			{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Agrupamento 1",								aAgrop[1],			;
		{;
		"1=Cliente", ;
		"2=Dt.Venc", ;
		"3=Dt.Emissao", ;
		"4=Banco", ;
		"5=Contrato", ;
		"6=Hierarquia de Vendas" ;
		},					120, ".T.", .F.})
	aadd(aPergs, {2, "Agrupamento 2",								aAgrop[2],			;
		{;
		"0=Não Aplicar", ;
		"1=Cliente", ;
		"2=Dt.Venc", ;
		"3=Dt.Emissao", ;
		"4=Banco", ;
		"5=Contrato", ;
		"6=Hierarquia de Vendas" ;
		},					120, ".T.", .F.})
	aadd(aPergs, {2, "Agrupamento 3",								aAgrop[3],			;
		{;
		"0=Não Aplicar", ;
		"1=Cliente", ;
		"2=Dt.Venc", ;
		"3=Dt.Emissao", ;
		"4=Banco", ;
		"5=Contrato", ;
		"6=Hierarquia de Vendas" ;
		},					120, ".T.", .F.})
	aadd(aPergs, {2, "Agrupamento 4",								aAgrop[4],			;
		{;
		"0=Não Aplicar", ;
		"1=Cliente", ;
		"2=Dt.Venc", ;
		"3=Dt.Emissao", ;
		"4=Banco", ;
		"5=Contrato", ;
		"6=Hierarquia de Vendas" ;
		},					120, ".T.", .F.})
	aadd(aPergs, {2, "Agrupamento 5",								aAgrop[5],			;
		{;
		"0=Não Aplicar", ;
		"1=Cliente", ;
		"2=Dt.Venc", ;
		"3=Dt.Emissao", ;
		"4=Banco", ;
		"5=Contrato", ;
		"6=Hierarquia de Vendas" ;
		},					120, ".T.", .F.})
	aadd(aPergs, {2, "Tipo de Periodo de data",						cTipPer,		;
		{;
		"1=Diário", ;
		"2=Semanal", ;
		"3=Quinzenal", ;
		"4=Mensal", ;
		"5=Semestral", ;
		"6=Anual" ;
		},					120, ".T.", .F.})
	aadd(aPergs, {2, "Tipo de Hierarquia vendas",					cTipHier,		;
		{;
		"1=Diretoria", ;
		"2=Regional", ;
		"3=Nome de vendedor" ;
		},					120, ".T.", .F.})
	if !ParamBox(aPergs, "Parâmetros do agrupamento")
		msgAlert("Os parametros não foram carregados", NOME_DO_FONTE)
		return
	else
		cProdSN		:= MV_PAR01
		cMovSN		:= MV_PAR02
		aAgrop[1]	:= MV_PAR03
		aAgrop[2]	:= MV_PAR04
		aAgrop[3]	:= MV_PAR05
		aAgrop[4]	:= MV_PAR06
		aAgrop[5]	:= MV_PAR07
		cTipPer		:= MV_PAR08
		cTipHier	:= MV_PAR09
	EndIf

	if cZeraJurSN == "1"
		cJur := "0"
		cMulta := "0"
	else
		if cJurPadSN == "1"
			cJur := "(E1.E1_PORCJUR * 100)"
			cMulta := "E1.E1_VLMULTA"
		else
			cJur := Str(nJur, 0, 6)
			cMulta := Str(nMulta, 0, 2)
		endIf
	endIf

	if cAouD == "1" // sem antecipacao e sem desconto
		nAntecipcao := 0
		nDesconto := 0
	elseIf cAouD == "2" // antecipacao
		nAntecipcao := nPerAD
		nDesconto := 0
	elseIf cAouD == "3" // desconto
		nAntecipcao := 0
		nDesconto := nPerAD
	else
		msgAlert("Não foi definido status do campo Antcipação/Desconto. Encerrar", NOME_DO_FONTE)
	endIf

	montaE1()
	If Select(cAliasE1) == 0
		msgAlert("Alias não cAliasE1 não existe. Encerrar", NOME_DO_FONTE)
		return
	EndIf

	oReport := fReportDef()
	oReport:PrintDialog()

	(cAliasE1)->(dbCloseArea()) // Fechando o alias cAliasE1
	restArea(areaPreserv)
return

/*/{Protheus.doc} fReportDef
	Funcao que gera o objeto do tipo TReport
	@type Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@return oReport, TReport
/*/
static function fReportDef()
	local nI			:= 0
	local oReport		:= Nil
	local oSecE1		:= Nil
	local aOBreak		:= {}
	local aOFuncCount	:= {}
	local aOFuncVOrig	:= {}
	local aOFuncVAtu	:= {}
	local aOFuncSaldo	:= {}

	//Criacao do componente de impressao
	oReport	:= TReport():New(;
		cAliasE1 /*cReport*/, ;
		"Titulos com detalhamento de produtos" /*cTitle*/, /*uParam*/, ;
		{|oReport| fGoPrint(oReport),} /*bAction*/, /*cDescription*/, ;
		.T. /*lLandscape*/, /*uTotalText*/, /*lTotalInLine*/, /*cPageTText*/, /*lPageTInLine*/, /*lTPageBreak*/, /*nColSpace*/)
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9)
	//Orientacao do Relatorio
	oReport:SetLandscape()
	//Definicoes da fonte utilizada
	oReport:SetLineHeight(35)
	oReport:nFontBody := 7

	//Criando a secao de dados da E1
	oSecE1	:= TRSection():New(;
		oReport /*oParent*/, ;
		"SecaoE1" /*cTitle*/, ;
		{cAliasE1} /*uTable*/, /*aOrder*/, /*lLoadCells*/, /*lLoadOrder*/, /*uTotalText*/, /*lTotalInLine*/, /*lHeaderPage*/, /*lHeaderBreak*/, /*lPageBreak*/, /*lLineBreak*/, /*nLeftMargin*/, /*lLineStyle*/, /*nColSpace*/, /*lAutoSize*/, /*cCharSeparator*/, /*nLinesBefore*/, /*nCols*/, /*nClrBack*/, /*nClrFore*/, /*nPercentage*/)
	oSecE1:SetTotalInLine(.F.)
	if cProdSN == "1"
		//Criando a secao de dados da D2
		oSecD2	:= TRSection():New(oSecE1, "SecaoD2", {cAliasD2}, , , , , , , , , , , , , , , , , , , )
	endIf
	if cMovSN == "1"
		//Criando a secao de dados da E5
		oSecE5	:= TRSection():New(oSecE1, "SecaoE5", {cAliasE5}, , , , , , , , , , , , , , , , , , , )
	endIf

	//Colunas do relatorio E1
	TRCell():New(;
		oSecE1 /*oParent*/, ;
		"CLI_COD" /*cName*/, ;
		cAliasE1 /*cAliasE1*/, ;
		"CodCli" /*cTitle*/, /*cPicture*/, ;
		10 /*nSize*/, /*lPixel*/, /*bBlock*/, ;
		"LEFT" /*cAlign*/, /*lLineBreak*/, ;
		"LEFT" /*lLineBreak*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, ;
		.T. /*lBold*/) // https://tdn.totvs.com/display/framework/TRCell
	TRCell():New(oSecE1, "LOJA", cAliasE1, "Loja", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "CLI_NOME", cAliasE1, "Cliente", , 25, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "PREFIXO", cAliasE1, "Prf", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "DOCUMENTO", cAliasE1, "Doc", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "PARCELA", cAliasE1, "Parc", , 3, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "TIPO", cAliasE1, "Tp", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "NATUREZA", cAliasE1, "Nature", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "EMISSAO", cAliasE1, "Emissao", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VENCIMENTO", cAliasE1, "Venc", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VENC_REAL", cAliasE1, "VencReal", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "BANCO", cAliasE1, "Bco", , 3, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "ST", cAliasE1, "St", , 2, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VL_ORIG", cAliasE1, "V.Orig", "@E 9,999,999.99", 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "SALDO", cAliasE1, "V.Atual", "@E 9,999,999.99", 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	//TRCell():New(oSecE1, "NUMBCO", cAliasE1, "NumBco", , 16, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VL_JUROS", cAliasE1, "Juro", "@E 999,999.99", 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "ATRASO", cAliasE1, "Atraso", , 6, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VL_CORRIG", cAliasE1, "V.Corri", "@E 9,999,999.99", 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	for nI := len(aBreak) to 1 step -1
		if aBreak[nI] $ "VEND_NOME#VEND_GER#VEND_REGI"
			TRCell():New(oSecE1, "VEND_NOME", cAliasE1, "Vendedor", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
			TRCell():New(oSecE1, "VEND_GER", cAliasE1, "Gerente", , 8, , , "LEFT" , , "LEFT" , , , , , , .T.)
			TRCell():New(oSecE1, "VEND_REGI", cAliasE1, "Regional", , 8, , , "LEFT" , , "LEFT" , , , , , , .T.)
		endIf
		if aBreak[nI] == "CONTRATO"
			TRCell():New(oSecE1, "CONTRATO", cAliasE1, "Vendedor", , 8, , , "LEFT" , , "LEFT" , , , , , , .T.)
		endIf
		if aBreak[nI] $ "WVENCTO#QVENCTO#MVENCTO#SVENCTO#AVENCTO#EMISSAO#WEMISSAO#QEMISSAO#MEMISSAO#SEMISSAO#AEMISSAO"
			TRCell():New(oSecE1, aBreak[nI], cAliasE1, "Oculto", , 1, , , "LEFT" , , "LEFT" , , , , , , .T.)
		endIf
		//Quebras do relatorio
		aAdd(aOBreak, TRBreak():New(oSecE1, oSecE1:Cell(aBreak[nI]), , .F.))
		//Totalizadores
		aAdd(aOFuncCount, TRFunction():New(oSecE1:Cell("CLI_COD"), , "COUNT", aOBreak[1 + len(aBreak) - nI], , "@E 999,999", , .F.)) // https://tdn.totvs.com/display/public/framework/TRFunction
		aAdd(aOFuncVOrig, TRFunction():New(oSecE1:Cell("VL_ORIG"), , "SUM", aOBreak[1 + len(aBreak) - nI], , "@E 9,999,999.99", , .F.))
		aAdd(aOFuncVAtu, TRFunction():New(oSecE1:Cell("VL_CORRIG"), , "SUM", aOBreak[1 + len(aBreak) - nI], , "@E 9,999,999.99", , .F.))
		aAdd(aOFuncSaldo, TRFunction():New(oSecE1:Cell("SALDO"), , "SUM", aOBreak[1 + len(aBreak) - nI], , "@E 9,999,999.99", , .F.))
	next

	if cMovSN == "1"
		// Colunas do relatorio E5
		TRCell():New(oSecE5, "PREFIXO", cAliasE5, "Prf", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "NUMERO", cAliasE5, "Doc", , 13, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "PARCELA", cAliasE5, "Parc", , 3, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "DATA_MOV", cAliasE5, "Dt.Mov", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "VALOR_MOV", cAliasE5, "Valor", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "BANCO_MOV", cAliasE5, "Banc", , 3, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "AGENCIA_MOV", cAliasE5, "Agencia", , 6, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "CONTA_MOV", cAliasE5, "Conta", , 9, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "DOC_MOV", cAliasE5, "Documento", , 13, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "HISTORICO", cAliasE5, "Historico", , 15, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecE5, "MOTV_BAIXA", cAliasE5, "Motivo", , 5, , , "LEFT" , , "LEFT" , , , , , , .T.)
	endIf

	if cProdSN == "1"
		// Colunas do relatorio D2
		TRCell():New(oSecD2, "ITEM", cAliasD2, "Item", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecD2, "PROD_COD", cAliasD2, "Cod", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecD2, "PROD_DESCRI", cAliasD2, "Produto", , 40, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecD2, "QUANTIDADE", cAliasD2, "Quant", , 6, , , "LEFT" , , "LEFT" , , , , , , .T.)
		TRCell():New(oSecD2, "UNIDADE", cAliasD2, "Un", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	endIf

	

return oReport

/*/{Protheus.doc} fGoPrint
	Funcao que é chamada no momento da impressão.
	@type Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@param oReport, TReport,
/*/
static function fGoPrint(oReport)
	local nAtual			:= 0
	local nTotal			:= 0
	local lAliasE1Vazio		:= .T.
	local cFilialControle	:= ""
	local cPrefixControle	:= ""
	local cDocumeControle	:= ""
	local cLojaControle		:= ""

	//Pegando as secoes do relatorio
	oSecE1 := oReport:Section(1)

	Count to nTotal
	oReport:SetMeter(nTotal)

	dbGoTop()
	cFilialControle 	:= (cAliasE1)->FILIAL
	cPrefixControle 	:= (cAliasE1)->PREFIXO
	cDocumeControle 	:= (cAliasE1)->DOCUMENTO
	cParcelControle		:= (cAliasE1)->PARCELA
	cCodCliControle 	:= (cAliasE1)->CLI_COD
	cLojaControle		:= (cAliasE1)->LOJA
	// Enquanto houver dados
	oSecE1:Init()
	while !(cAliasE1)->(Eof())
		nAtual++
		lAliasE1Vazio := .F. // Indica que houve pelo menos um registro no alias cAliasE1
		oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		oReport:IncMeter()
		if (cFilialControle == (cAliasE1)->FILIAL .and. cPrefixControle == (cAliasE1)->PREFIXO .and. cDocumeControle == (cAliasE1)->DOCUMENTO .and. cParcelControle == (cAliasE1)->PARCELA) // Mesmo titulo
			oSecE1:PrintLine()
			(cAliasE1)->(dbSkip())
		else // Outro titulo
			//oSecE1:Finish()
			if cMovSN == "1"
				printE5(cFilialControle, cPrefixControle, cDocumeControle, cParcelControle, cCodCliControle, cLojaControle)
			endIf
			if cProdSN == "1"
				printD2(cFilialControle, cDocumeControle, cCodCliControle, cLojaControle)
			endIf
			cFilialControle 	:= (cAliasE1)->FILIAL
			cPrefixControle 	:= (cAliasE1)->PREFIXO
			cDocumeControle 	:= (cAliasE1)->DOCUMENTO
			cParcelControle		:= (cAliasE1)->PARCELA
			cCodCliControle 	:= (cAliasE1)->CLI_COD
			cLojaControle		:= (cAliasE1)->LOJA
			//oSecE1:Init()
			DbSelectArea(cAliasE1)
		end
	endDo
	oSecE1:Finish()
	if !lAliasE1Vazio .and. (cProdSN == "1")
		printD2(cFilialControle, cDocumeControle, cCodCliControle, cLojaControle)
	endIf
return

/*/{Protheus.doc} printE5
	Funcao que imprime a Section com dados do financeiro, dados da tabela SE5
	@type Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@param cFilialControle, c, Filial
	@param cPrefixControle, c, Prefixo do titulo
	@param cDocumeControle, c, Numero do titulo
	@param cParcelControle, c, Numero da parcela
	@param cCodCliControle, c, codigo do cliente
	@param cLojaControle, c, loja do cliente
/*/
static function printE5(cFilialControle, cPrefixControle, cDocumeControle, cParcelControle, cCodCliControle, cLojaControle)
	local lAliasE5Vazio		:= .T.

	montaE5(cFilialControle, cPrefixControle, cDocumeControle, cParcelControle, cCodCliControle, cLojaControle)
	dbSelectArea(cAliasE5)
	if !(cAliasE5)->(Eof())
		lAliasE5Vazio := .F. // Indica que houve pelo menos um registro no alias cAliasE5
		oSecE5:Init()
		while !(cAliasE5)->(Eof())
			oSecE5:PrintLine()
			(cAliasE5)->(dbSkip())
		endDo
		oSecE5:Finish()
		(cAliasE5)->(dbCloseArea()) // Fechando o alias cAliasE5
	endIf
return

/*/{Protheus.doc} montaE5
	Funcao que monta o cAliasE5
	@type Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@param cFil, c, Filial
	@param cPrefix, c, Prefixo do titulo
	@param cDoc, c, Numero do titulo
	@param cParcel, c, Numero da parcela
	@param cCodCli, c, Codigo do cliente
	@param cLoja, c, Loja do cliente
/*/
static function montaE5(cFil, cPrefix, cDoc, cParcel, cCodCli, cLoja)
	local cQueryX	:= ""

	cQueryX += "SELECT " + CRLF
	cQueryX += "	E5.R_E_C_N_O_ AS E5_REC, " + CRLF
	cQueryX += "	E5.E5_PREFIXO AS PREFIXO, " + CRLF
	cQueryX += "	E5.E5_NUMERO AS NUMERO, " + CRLF
	cQueryX += "	E5.E5_PARCELA AS PARCELA, " + CRLF
	cQueryX += "	SUBSTRING(E5.E5_DATA, 7, 2) || '/' || SUBSTRING(E5.E5_DATA, 5, 2) || '/' || SUBSTRING(E5.E5_DATA, 1, 4) AS DATA_MOV, " + CRLF
	cQueryX += "	E5.E5_VALOR AS VALOR_MOV, " + CRLF
	cQueryX += "	E5.E5_BANCO AS BANCO_MOV, " + CRLF
	cQueryX += "	E5.E5_AGENCIA AS AGENCIA_MOV, " + CRLF
	cQueryX += "	E5.E5_CONTA AS CONTA_MOV, " + CRLF
	cQueryX += "	E5.E5_DOCUMEN AS DOC_MOV, " + CRLF
	cQueryX += "	E5.E5_HISTOR AS HISTORICO, " + CRLF
	cQueryX += "	E5.E5_MOTBX AS MOTV_BAIXA " + CRLF
	cQueryX += "FROM " + CRLF
	cQueryX += "	" + RetSqlName("SE5") + " E5 " + CRLF
	cQueryX += "WHERE " + CRLF
	cQueryX += "	E5.E5_FILORIG = '" + cFil + "' " + CRLF
	cQueryX += "	AND E5.E5_PREFIXO = '" + cPrefix + "' " + CRLF
	cQueryX += "	AND E5.E5_NUMERO = '" + cDoc + "' " + CRLF
	cQueryX += "	AND E5.E5_PARCELA = '" + cParcel + "' " + CRLF
	cQueryX += "	AND E5.E5_TIPO = 'NF' " + CRLF
	cQueryX += "	AND E5.E5_CLIENTE = '" + cCodCli + "' " + CRLF
	cQueryX += "	AND E5.E5_LOJA = '" + cLoja + "' " + CRLF
	cQueryX += "	AND E5.D_E_L_E_T_ = '' " + CRLF
	cQueryX += "ORDER BY " + CRLF
	cQueryX += "	DATA_MOV " + CRLF

	#IFDEF MOSTRA_QUERY
		if cMostraE5
			ShowLog(cQueryX)
		endIf
	#ENDIF

	If Select(cAliasE5) > 0
		DbSelectArea(cAliasE5)
		(cAliasE5)->(dbCloseArea())
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQueryX)), cAliasE5, .F., .T.)
return



/*/{Protheus.doc} printD2
	Funcao que imprime a Section com dados do faturamento, dados da tabela SD2
	@type Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@param cFilialControle, c, Filial
	@param cDocumeControle, c, Numero do titulo e numero da NF
	@param cCodCliControle, c, Codigo do cliente
	@param cLojaControle, c, Loja do cliente
/*/
static function printD2(cFilialControle, cDocumeControle, cCodCliControle, cLojaControle)
	local lAliasD2Vazio		:= .T.

	montaD2(cFilialControle, cDocumeControle, cCodCliControle, cLojaControle)
	dbSelectArea(cAliasD2)
	if !(cAliasD2)->(Eof())
		lAliasD2Vazio := .F. // Indica que houve pelo menos um registro no alias cAliasD2
		oSecD2:Init()
		while !(cAliasD2)->(Eof())
			oSecD2:PrintLine()
			(cAliasD2)->(dbSkip())
		endDo
		oSecD2:Finish()
		(cAliasD2)->(dbCloseArea()) // Fechando o alias cAliasD2
	endIf
return

/*/{Protheus.doc} montaD2
	Funcao que monta o cAliasD2
	@type Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@param cFil, c, Filial
	@param cDoc, c, Numero do titulo e numero da NF
	@param cCodCli, c, Codigo do cliente
	@param cLoja, c, Loja
/*/
static function montaD2(cFil, cDoc, cCodCli, cLoja)
	local cQueryX	:= ""

	cQueryX += "SELECT " + CRLF
	cQueryX += "	D2.R_E_C_N_O_ AS D2_REC, " + CRLF
	cQueryX += "	D2.D2_FILIAL, " + CRLF
	cQueryX += "	D2.D2_CLIENTE, " + CRLF
	cQueryX += "	D2.D2_LOJA, " + CRLF
	cQueryX += "	D2.D2_SERIE AS SERIE, " + CRLF
	cQueryX += "	D2.D2_ITEM AS ITEM, " + CRLF
	cQueryX += "	D2.D2_COD AS PROD_COD, " + CRLF
	cQueryX += "	B1.B1_DESC AS PROD_DESCRI, " + CRLF
	cQueryX += "	D2.D2_QUANT AS QUANTIDADE, " + CRLF
	cQueryX += "	D2.D2_UM AS UNIDADE, " + CRLF
	cQueryX += "	D2.D2_PRCVEN AS PRC_UNIT, " + CRLF
	cQueryX += "	D2.D2_TOTAL AS PRC_ITEM, " + CRLF
	cQueryX += "	D2.D2_QUANT * D2.D2_PRCVEN AS MULTIPLI_OK " + CRLF
	cQueryX += "FROM " + CRLF
	cQueryX += "	" + RetSqlName("SD2") + " D2 " + CRLF
	cQueryX += "	INNER JOIN " + CRLF
	cQueryX += "		" + RetSqlName("SB1") + " B1 " + CRLF
	cQueryX += "		ON D2.D2_COD = B1.B1_COD " + CRLF
	cQueryX += "		AND B1.D_E_L_E_T_ = '' " + CRLF
	cQueryX += "WHERE " + CRLF
	cQueryX += "	D2.D2_DOC = '" + cDoc + "' " + CRLF
	cQueryX += "	AND D2.D2_FILIAL = '" + cFil + "' " + CRLF
	cQueryX += "	AND D2.D2_CLIENTE = '" + cCodCli + "' " + CRLF
	cQueryX += "	AND D2.D2_LOJA = '" + cLoja + "' " + CRLF
	if cPrdG != "1" // todos
		if cPrdG == "2" // CRF
			cQueryX += "	AND B1.B1_GRUPO IN('2', '21', '2101') " + CRLF
		elseIf cPrdG == "3" // Specialties
			cQueryX += "	AND B1.B1_GRUPO IN('1') " + CRLF
		elseIf cPrdG == "4" // Biologics/BioControl
			cQueryX += "	AND B1.B1_GRUPO IN('3', '32') " + CRLF
		endIf
	endIf
	cQueryX += "	AND D2.D_E_L_E_T_ = '' " + CRLF
	cQueryX += "ORDER BY " + CRLF
	cQueryX += "	ITEM " + CRLF

	#IFDEF MOSTRA_QUERY
		if cMostraD2
			ShowLog(cQueryX)
		endIf
	#ENDIF

	If Select(cAliasD2) > 0
		DbSelectArea(cAliasD2)
		(cAliasD2)->(dbCloseArea())
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQueryX)), cAliasD2, .F., .T.)
return

/*/{Protheus.doc} montaE1
	Funcao que monta o cAliasE1
	@type Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
/*/
static function montaE1()
	local cQuery1			:= ""

	cQuery1 := montaQueryE1(cFil, cCli, cSit, cDtVenc0, cDtVenc1, cDtEmis0, cDtEmis1)

	#IFDEF MOSTRA_QUERY
		if MsgYesNo("Mostrar Query E1", NOME_DO_FONTE)
			ShowLog(cQuery1)
			return
		endIf
	#ENDIF

	If Select(cAliasE1) > 0
		DbSelectArea(cAliasE1)
		(cAliasE1)->(dbCloseArea())
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery1)), cAliasE1, .F., .T.)
	dbSelectArea(cAliasE1)

	If (cAliasE1)->(Eof())
		msgAlert("Nao existem dados no alias " + cAliasE1, NOME_DO_FONTE)
	endIf
return

/*/{Protheus.doc} montaQueryE1
	Funcao que monta a query que será usada para montar o cAliasE1
	@type Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@param cFil, c, Filial
	@param cCli, c, string com R_E_C_N_O_ de clientes
	@param cListaSituacoes, c, Lista com R_E_C_N_O_ de tipos de situacoes
	@param cDtVenc0, c, data de vencimento inicial do intervalo
	@param cDtVenc1, c, data de vencimento final do intervalo
	@param cDtEmis0, c, data de emissao inicio do intervalo
	@param cDtEmis1, c, data de emissao final do intervalo
/*/
static function montaQueryE1(cFil, cCli, cListaSituacoes, cDtVenc0, cDtVenc1, cDtEmis0, cDtEmis1)
	local nI		:= 0
	local nJ		:= 0
	local cQueryX	:= ""
	local cWhere1	:= ""
	local cOrder1	:= ""

	cWhere1 += "	WHERE " + CRLF
	cWhere1 += "		E1.E1_TIPO = 'NF' " + CRLF
	#IFNDEF SEM_PARAMETROS
		if empty(cFil)
			cFil := "('" + StrTran(xFilial("SE1"), " ", "", , ) + StrTran(fwFilial(), " ", "", , ) + "')"
		endIf
		cWhere1 += "		AND E1.E1_FILORIG IN " + cFil + " " + CRLF
		if !empty(cCli)
			cWhere1 += "		AND A1.R_E_C_N_O_ IN " + cCli + " " + CRLF
		endIf
		if !empty(cListaSituacoes)
			cWhere1 += "		AND E1.E1_SITUACA IN " + cListaSituacoes + " " + CRLF
		endIf
		cWhere1 += "		AND E1.E1_VENCREA BETWEEN '" + cDtVenc0 + "' AND '" + cDtVenc1 + "' " + CRLF
		cWhere1 += "		AND E1.E1_EMISSAO BETWEEN '" + cDtEmis0 + "' AND '" + cDtEmis1 + "' " + CRLF
		if !empty(cSafra) .and. cSafra != "0"
			cWhere1 += "		AND E1.E1_USAFRA = '" + cSafra + "' " + CRLF
		endIf
		if !empty(cCultura) .and. cCultura	!= "     "
			cWhere1 += "		AND E1.E1_UCULTUR = '" + cCultura + "' " + CRLF
		endIf
	#ENDIF
	cWhere1 += "		AND E1.E1_SALDO <> 0 " + CRLF
	cWhere1 += "		AND E1.D_E_L_E_T_ = '' " + CRLF

	for nI := 1 to len(aAgrop)
		for nJ := nI to len(aAgrop)
			if aAgrop[nI] == aAgrop[nJ] .and. nI < nJ
				aAgrop[nJ] := "0"
			endIf
		next
	next
	cOrder1 += "ORDER BY " + CRLF + "	"

	for nI := 1 to len(aAgrop)
		if aAgrop[nI] == "1"
			cOrder1 += ", CLI_COD"
			aAdd(aBreak, "CLI_COD")
		elseIf aAgrop[nI] == "2" // por vencimento
			cOrder1 += ", VENC_REAL"
			if cTipPer == "1" // Diário
				aAdd(aBreak, "VENC_REAL")
			elseIf cTipPer == "2" // Semanal
				aAdd(aBreak, "WVENCTO")
			elseIf cTipPer == "3" // Quinzenal
				aAdd(aBreak, "QVENCTO")
			elseIf cTipPer == "4" // Mensal
				aAdd(aBreak, "MVENCTO")
			elseIf cTipPer == "5" // Semestral
				aAdd(aBreak, "SVENCTO")
			elseIf cTipPer == "6" // Anual
				aAdd(aBreak, "AVENCTO")
			else
				msgAlert("falha no tipo de agrupamento (tipo de periodo)", NOME_DO_FONTE)
			endIf
		elseIf aAgrop[nI] == "3" // por emissao
			cOrder1 += ", EMISSAO"
			if cTipPer == "1" // Diário
				aAdd(aBreak, "EMISSAO")
			elseIf cTipPer == "2" // Semanal
				aAdd(aBreak, "WEMISSAO")
			elseIf cTipPer == "3" // Quinzenal
				aAdd(aBreak, "QEMISSAO")
			elseIf cTipPer == "4" // Mensal
				aAdd(aBreak, "MEMISSAO")
			elseIf cTipPer == "5" // Semestral
				aAdd(aBreak, "SEMISSAO")
			elseIf cTipPer == "6" // Anual
				aAdd(aBreak, "AEMISSAO")
			else
				msgAlert("falha no tipo de agrupamento (tipo de periodo)", NOME_DO_FONTE)
			endIf
		elseIf aAgrop[nI] == "4" // por banco
			cOrder1 += ", BANCO DESC"
			aAdd(aBreak, "BANCO")
		elseIf aAgrop[nI] == "5" // por contrato
			cOrder1 += ", CONTRATO"
			aAdd(aBreak, "CONTRATO")
		elseIf aAgrop[nI] == "6" // por hierarquia de vendas
			if cTipHier == "1" // por diretoria
				cOrder1 += ", VEND_GER"
				aAdd(aBreak, "VEND_GER")
			elseIf cTipHier == "2" // por regiao
				cOrder1 += ", VEND_REGI"
				aAdd(aBreak, "VEND_REGI")
			elseIf cTipHier == "3" // por nome de vendedor
				cOrder1 += ", VEND_NOME"
				aAdd(aBreak, "VEND_NOME")
			else
				msgAlert("falha no tipo de agrupamento (hierarquia)", NOME_DO_FONTE)
			endIf
		endIf
	next
	cOrder1 += ", LOJA, DOCUMENTO, PARCELA " + CRLF
	cOrder1 := StrTran(cOrder1, "	, ", "	", , ) // https://tdn.totvs.com/display/public/framework/StrTran
	#IFDEF MOSTRA_QUERY
		ShowLog(cOrder1)
	#ENDIF

	cQueryX += "SELECT " + CRLF
	cQueryX += "	E1_EXT.E1_REC, " + CRLF
	cQueryX += "	E1_EXT.FILIAL, " + CRLF
	cQueryX += "	E1_EXT.CLI_COD, " + CRLF
	cQueryX += "	E1_EXT.LOJA, " + CRLF
	cQueryX += "	E1_EXT.CLI_NOME, " + CRLF
	cQueryX += "	E1_EXT.PREFIXO, " + CRLF
	cQueryX += "	E1_EXT.DOCUMENTO, " + CRLF
	cQueryX += "	E1_EXT.PARCELA, " + CRLF
	cQueryX += "	E1_EXT.TIPO, " + CRLF
	cQueryX += "	E1_EXT.NATUREZA, " + CRLF
	cQueryX += "	E1_EXT.EMISSAO, " + CRLF
	cQueryX += "	E1_EXT.VENCIMENTO, " + CRLF
	cQueryX += "	E1_EXT.VENC_REAL, " + CRLF
	cQueryX += "	E1_EXT.BANCO, " + CRLF
	cQueryX += "	E1_EXT.ST, " + CRLF
	cQueryX += "	E1_EXT.CONTRATO, " + CRLF
	cQueryX += "	E1_EXT.VL_ORIG, " + CRLF
	cQueryX += "	E1_EXT.TX_JUROS, " + CRLF
	cQueryX += "	E1_EXT.MULTA, " + CRLF
	cQueryX += "	CASE " + CRLF
	cQueryX += "		WHEN E1_EXT.ATRASO > 0 THEN TO_CHAR(E1_EXT.ATRASO) ELSE '' " + CRLF
	cQueryX += "	END AS ATRASO, " + CRLF
	cQueryX += "	E1_EXT.E1_EMISSAO, " + CRLF
	cQueryX += "	E1_EXT.E1_VENCREA, " + CRLF
	cQueryX += "	E1_EXT.WEMISSAO, " + CRLF
	cQueryX += "	E1_EXT.WVENCTO, " + CRLF
	cQueryX += "	E1_EXT.QEMISSAO, " + CRLF
	cQueryX += "	E1_EXT.QVENCTO, " + CRLF
	cQueryX += "	E1_EXT.MEMISSAO, " + CRLF
	cQueryX += "	E1_EXT.MVENCTO, " + CRLF
	cQueryX += "	E1_EXT.SEMISSAO, " + CRLF
	cQueryX += "	E1_EXT.SVENCTO, " + CRLF
	cQueryX += "	E1_EXT.AEMISSAO, " + CRLF
	cQueryX += "	E1_EXT.AVENCTO, " + CRLF
	cQueryX += "	E1_EXT.SALDO, " + CRLF
	cQueryX += "	E1_EXT.NUMBCO, " + CRLF
	cQueryX += "	E1_EXT.ULTIMA_BAIXA, " + CRLF
	cQueryX += "	E1_EXT.VEND_COD, " + CRLF
	cQueryX += "	E1_EXT.VEND_NOME, " + CRLF
	cQueryX += "	E1_EXT.VEND_REGI, " + CRLF
	cQueryX += "	E1_EXT.VEND_GER, " + CRLF
	cQueryX += "	CASE " + CRLF
	cQueryX += "		WHEN E1_EXT.ATRASO > 0 THEN E1_EXT.SALDO ELSE 0 " + CRLF
	cQueryX += "	END AS VL_VENCIDO, " + CRLF
	cQueryX += "	CASE " + CRLF
	cQueryX += "		WHEN E1_EXT.ATRASO > 0  " + CRLF
	cQueryX += "		THEN ROUND(E1_EXT.SALDO * (1 + (E1_EXT.TX_JUROS * E1_EXT.ATRASO + E1_EXT.MULTA) / 100) * (1 - " + cValToChar(nDesconto) + " / 100), 2) " + CRLF
	cQueryX += "		ELSE ROUND(E1_EXT.SALDO * (1 - " + cValToChar(nAntecipcao) + " / 100) * (1 - " + cValToChar(nDesconto) + " / 100), 2) " + CRLF
	cQueryX += "	END AS VL_CORRIG, " + CRLF
	cQueryX += "	CASE " + CRLF
	cQueryX += "		WHEN E1_EXT.ATRASO > 0 THEN ROUND(E1_EXT.SALDO * ((E1_EXT.TX_JUROS * E1_EXT.ATRASO + E1_EXT.MULTA) / 100), 2) ELSE 0 " + CRLF
	cQueryX += "	END AS VL_JUROS " + CRLF
	cQueryX += "FROM " + CRLF
	cQueryX += "	( " + CRLF
	cQueryX += "	SELECT " + CRLF
	cQueryX += "		E1.R_E_C_N_O_ AS E1_REC, " + CRLF
	cQueryX += "		E1.E1_FILORIG AS FILIAL, " + CRLF
	cQueryX += "		A1.A1_COD AS CLI_COD, " + CRLF
	cQueryX += "		A1.A1_LOJA AS LOJA, " + CRLF
	cQueryX += "		A1.A1_NOME AS CLI_NOME, " + CRLF
	cQueryX += "		E1.E1_PREFIXO AS PREFIXO, " + CRLF
	cQueryX += "		E1.E1_NUM AS DOCUMENTO, " + CRLF
	cQueryX += "		E1.E1_PARCELA AS PARCELA, " + CRLF
	cQueryX += "		E1.E1_TIPO AS TIPO, " + CRLF
	cQueryX += "		E1.E1_NATUREZ AS NATUREZA, " + CRLF
	cQueryX += "		SUBSTR(E1.E1_EMISSAO, 7, 2) || '/' || SUBSTR(E1.E1_EMISSAO, 5, 2) || '/' || SUBSTR(E1.E1_EMISSAO, 1, 4) AS EMISSAO, " + CRLF
	cQueryX += "		SUBSTR(E1.E1_VENCTO, 7, 2) || '/' || SUBSTR(E1.E1_VENCTO, 5, 2) || '/' || SUBSTR(E1.E1_VENCTO, 1, 4) AS VENCIMENTO, " + CRLF
	cQueryX += "		SUBSTR(E1.E1_VENCREA, 7, 2) || '/' || SUBSTR(E1.E1_VENCREA, 5, 2) || '/' || SUBSTR(E1.E1_VENCREA, 1, 4) AS VENC_REAL, " + CRLF
	cQueryX += "		E1_PORTADO AS BANCO, " + CRLF
	cQueryX += "		E1.E1_SITUACA AS ST, " + CRLF
	cQueryX += "		E1.E1_CONTRAT AS CONTRATO, " + CRLF
	cQueryX += "		E1.E1_VALOR AS VL_ORIG, " + CRLF
	cQueryX += "		" + cJur + " AS TX_JUROS, " + CRLF
	cQueryX += "		" + cMulta + " AS MULTA, " + CRLF
	cQueryX += "		TRUNC(SYSDATE) - TO_DATE(E1.E1_VENCREA, 'YYYYMMDD') AS ATRASO, " + CRLF
	cQueryX += "		E1.E1_EMISSAO, " + CRLF
	cQueryX += "		E1.E1_VENCREA, " + CRLF
	cQueryX += "		TRUNC((TO_DATE(E1.E1_EMISSAO, 'YYYYMMDD') - TO_DATE('19700101', 'YYYYMMDD')) / 7) AS WEMISSAO, " + CRLF
	cQueryX += "		TRUNC((TO_DATE(E1.E1_VENCREA, 'YYYYMMDD') - TO_DATE('19700101', 'YYYYMMDD')) / 7) AS WVENCTO, " + CRLF
	cQueryX += "		CASE " + CRLF
	cQueryX += "			WHEN SUBSTR(E1.E1_EMISSAO, 7, 2) <= 15 " + CRLF
	cQueryX += "			THEN SUBSTR(E1.E1_EMISSAO, 1, 6) || '.1' " + CRLF
	cQueryX += "			ELSE SUBSTR(E1.E1_EMISSAO, 1, 6) || '.2' " + CRLF
	cQueryX += "		END AS QEMISSAO,  " + CRLF
	cQueryX += "		CASE " + CRLF
	cQueryX += "			WHEN SUBSTR(E1.E1_VENCREA, 7, 2) <= 15 " + CRLF
	cQueryX += "			THEN SUBSTR(E1.E1_VENCREA, 1, 6) || '.1' " + CRLF
	cQueryX += "			ELSE SUBSTR(E1.E1_VENCREA, 1, 6) || '.2' " + CRLF
	cQueryX += "		END AS QVENCTO,  " + CRLF
	cQueryX += "		SUBSTR(E1.E1_EMISSAO, 1, 6) AS MEMISSAO, " + CRLF
	cQueryX += "		SUBSTR(E1.E1_VENCREA, 1, 6) AS MVENCTO, " + CRLF
	cQueryX += "		CASE " + CRLF
	cQueryX += "			WHEN SUBSTR(E1.E1_EMISSAO, 5, 2) <= 6 " + CRLF
	cQueryX += "			THEN SUBSTR(E1.E1_EMISSAO, 1, 4) || '.1' " + CRLF
	cQueryX += "			ELSE SUBSTR(E1.E1_EMISSAO, 1, 4) || '.2' " + CRLF
	cQueryX += "		END AS SEMISSAO,  " + CRLF
	cQueryX += "		CASE " + CRLF
	cQueryX += "			WHEN SUBSTR(E1.E1_VENCREA, 5, 2) <= 6 " + CRLF
	cQueryX += "			THEN SUBSTR(E1.E1_VENCREA, 1, 4) || '.1' " + CRLF
	cQueryX += "			ELSE SUBSTR(E1.E1_VENCREA, 1, 4) || '.2' " + CRLF
	cQueryX += "		END AS SVENCTO, " + CRLF
	cQueryX += "		SUBSTR(E1.E1_EMISSAO, 1, 4) AS AEMISSAO, " + CRLF
	cQueryX += "		SUBSTR(E1.E1_VENCREA, 1, 4) AS AVENCTO, " + CRLF
	cQueryX += "		E1.E1_SALDO AS SALDO, " + CRLF
	cQueryX += "		E1.E1_NUMBCO AS NUMBCO, " + CRLF
	cQueryX += "		E1.E1_BAIXA AS ULTIMA_BAIXA, " + CRLF
	cQueryX += "		A3.A3_COD AS VEND_COD, " + CRLF
	cQueryX += "		A3.A3_NOME AS VEND_NOME, " + CRLF
	cQueryX += "		A3.A3_REGIAO AS VEND_REGI, " + CRLF
	cQueryX += "		A3.A3_GEREN AS VEND_GER " + CRLF
	cQueryX += "	FROM " + CRLF
	cQueryX += "		" + RetSqlName("SE1") + " E1 " + CRLF
	cQueryX += "		INNER JOIN " + CRLF
	cQueryX += "			" + RetSqlName("SA1") + " A1 " + CRLF
	cQueryX += "			ON E1.E1_CLIENTE = A1.A1_COD " + CRLF
	cQueryX += "			AND E1.E1_LOJA = A1.A1_LOJA " + CRLF
	cQueryX += "			AND A1.D_E_L_E_T_ = '' " + CRLF
	cQueryX += "		LEFT JOIN " + CRLF
	cQueryX += "			" + RetSqlName("SA3") + " A3 " + CRLF
	cQueryX += "			ON E1.E1_VEND1 = A3.A3_COD " + CRLF
	cQueryX += "			AND A3.D_E_L_E_T_ = '' " + CRLF
	cQueryX += cWhere1
	cQueryX += "	) E1_EXT " + CRLF
	cQueryX += cOrder1

return cQueryX

/*
	https://terminaldeinformacao.com/2024/02/27/abrindo-uma-tela-para-marcacao-de-registros-com-a-f_opcoes-maratona-advpl-e-tl-261/
	https://tdn.totvs.com/display/public/framework/FwListBranches
	https://terminaldeinformacao.com/knowledgebase/parambox/
	https://www.blacktdn.com.br/2012/05/para-quem-precisar-desenvolver-uma.html
	https://logostechnology.zendesk.com/hc/pt-br/articles/360048936174-ADVPL-Tipos-e-par%C3%A2metros-da-fun%C3%A7%C3%A3o-ParamBox-em-ADVPL
	https://tdn.totvs.com/display/public/framework/StrTran
	https://tdn.totvs.com/display/public/framework/TRFunction
*/
