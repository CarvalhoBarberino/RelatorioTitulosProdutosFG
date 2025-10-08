#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"

#DEFINE SEM_PARAMETROS // Usado para testes durante o desenvolvimento

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

	private oSecE1		:= Nil
	private oSecE5		:= Nil
	private oSecD2		:= Nil
	private cAliasE1	:= "UFINR85E1"
	private cAliasE5	:= "UFINR85E5"
	private cAliasD2	:= "UFINR85D2"
	private cFilSN		:= "2"
	private cProdSN		:= "1"
	private cMovSN		:= "1"
	private cJurPadSN	:= "2"
	private nJur		:= 0
	private cJur		:= ""
	private nMulta		:= 0
	private cMulta		:= ""
	private cZeraJurSN	:= "2"
	private cTipG		:= "1"
	private cPrdG		:= "1"

	aadd(aPergs, {2, "Selecionar filiais especificas?",				cFilSN,			{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Imprime Produtos ao final de cada título?",	cProdSN,		{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Mostra informacoes de baixa?",				cMovSN,			{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Zerar taxas e multas?",						cZeraJurSN,		{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {2, "Taxas de juros padrão?",						cJurPadSN,		{"1=Sim", "2=Não"},					80, ".T.", .F.})
	aadd(aPergs, {1, "TxJurosMensal",								nJur,		"@E 999.99",	".T.",	"",	".T.",	80,	.F.})
	aadd(aPergs, {1, "Multa",										nMulta,		"@E 99,999.99",	".T.",	"",	".T.",	80,	.F.})
	aadd(aPergs, {2, "Tipo de agrupamento?",						cTipG,		;
		{;
		"1=Cliente", ;
		"2=Dt.Venc", ;
		"3=Dt.Emissao", ;
		"4=Diário", ;
		"5=Semanal", ;
		"6=Quinzenal", ;
		"7=Mensal", ;
		"8=Semestral", ;
		"9=Anual", ;
		"10=Banco", ;
		"11=Contrato", ;
		"12=Hierarquia Com. Diretoria", ;
		"13=Hierarquia Com. Regional", ;
		"14=Hierarquia Com. Vendedor", ;
		},					120, ".T.", .F.})
	aadd(aPergs, {2, "Grupo de produto?",						cPrdG,		;
		{;
		"1=CRF", ;
		"2=Especialidade", ;
		"3=Biologico", ;
		"4=Outros", ;
		},					120, ".T.", .F.})
	if !ParamBox(aPergs, "Informe os parâmetros")
		msgAlert("Os parametros não foram carregados", "UFINR85.PRW")
		return
	else
		cFilSN		:= MV_PAR01
		cProdSN		:= MV_PAR02
		cMovSN		:= MV_PAR03
		cZeraJurSN	:= MV_PAR04
		cJurPadSN	:= MV_PAR05
		nJur		:= MV_PAR06
		nMulta		:= MV_PAR07
		cTipG		:= MV_PAR08
		cPrdG		:= MV_PAR09
	EndIf

	if cFilSN == "1"
		// Seleciona filiais
	endIf

	if cZeraJurSN == "1"
		nJur := 0
		nMulta := 0
	elseIf cJurPadSN == "1"
		//usar juros padrão
	else
		cJur := Str(nJur, 0, 2)
		cMulta := Str(nMulta, 0, 2)
	endIf

	
	montaE1()

	oReport := fReportDef()
	oReport:PrintDialog()

	(cAliasE1)->(dbCloseArea()) // Fechando o alias cAliasE1
	restArea(areaPreserv)	
return

/*/{Protheus.doc} fReportDef
	Funcao que gera o objeto do tipo TReport
	@type  Static Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@return oReport, TReport, 
	@example
	(examples)
	@see (links_or_references)
/*/
static function fReportDef()
	local oReport

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
	oReport:nFontBody := 9

	//Criando a secao de dados da E1
	oSecE1	:= TRSection():New(;
		oReport /*oParent*/, ;
		"SecaoE1" /*cTitle*/, ;
		{cAliasE1} /*uTable*/, /*aOrder*/, /*lLoadCells*/, /*lLoadOrder*/, /*uTotalText*/, /*lTotalInLine*/, /*lHeaderPage*/, /*lHeaderBreak*/, /*lPageBreak*/, /*lLineBreak*/, /*nLeftMargin*/, /*lLineStyle*/, /*nColSpace*/, /*lAutoSize*/, /*cCharSeparator*/, /*nLinesBefore*/, /*nCols*/, /*nClrBack*/, /*nClrFore*/, /*nPercentage*/)
	if cProdSN == "1"
		//Criando a secao de dados da D2
		oSecD2	:= TRSection():New(oReport, "SecaoD2", {cAliasE1}, , , , , , , , , , , , , , , , , , , )
	endIf
	if cMovSN == "1"
		//Criando a secao de dados da E5
		oSecE5	:= TRSection():New(oReport, "SecaoE5", {cAliasE5}, , , , , , , , , , , , , , , , , , , )
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
		.T. /*lBold*/)
	TRCell():New(oSecE1, "LOJA", cAliasE1, "Loja", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "CLI_NOME", cAliasE1, "Cliente", , 25, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "PREFIXO", cAliasE1, "Prf", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "DOCUMENTO", cAliasE1, "Doc", , 13, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "PARCELA", cAliasE1, "Parc", , 3, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "TIPO", cAliasE1, "Tp", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "NATUREZA", cAliasE1, "Nature", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "EMISSAO", cAliasE1, "Emissao", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VENCIMENTO", cAliasE1, "Venc", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VENC_REAL", cAliasE1, "VencReal", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "BANCO", cAliasE1, "Bco", , 3, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "ST", cAliasE1, "St", , 2, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VL_ORIG", cAliasE1, "V.Orig", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "SALDO", cAliasE1, "V.Atual", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	//TRCell():New(oSecE1, "NUMBCO", cAliasE1, "NumBco", , 16, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "VL_JUROS", cAliasE1, "Juro", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1, "ATRASO", cAliasE1, "Atraso", , 6, , , "LEFT" , , "LEFT" , , , , , , .T.)

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

	//Quebras do relatorio
	oBreak := TRBreak():New(oSecE1, oSecE1:Cell("CLI_COD"), {||"Total da Quebra"}, .F.)



return oReport

/*/{Protheus.doc} fGoPrint
	Funcao que é chamada no momento da impressão.
	@type  static function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@param oReport, TReport,
/*/
static function fGoPrint(oReport)
	//local cPerg				:= "FIN130"
	local nAtual			:= 0
	local nTotal			:= 0
	local lAliasE1Vazio		:= .T.
	local cFilialControle	:= ""
	local cPrefixControle	:= ""
	local cDocumeControle	:= ""
	local cLojaControle		:= ""

	//Pegando as secoes do relatorio
	oSecE1 := oReport:Section(1)
	oSecD2 := oReport:Section(2)

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
			oSecE1:Finish()
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
			oSecE1:Init()
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
	@type static function
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
	@type static function
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

	cQueryX += "SELECT "
	cQueryX += "	E5.R_E_C_N_O_ AS E5_REC, "
	cQueryX += "	E5.E5_PREFIXO AS PREFIXO, "
	cQueryX += "	E5.E5_NUMERO AS NUMERO, "
	cQueryX += "	E5.E5_PARCELA AS PARCELA, "
	cQueryX += "	SUBSTRING(E5.E5_DATA, 7, 2) || '/' || SUBSTRING(E5.E5_DATA, 5, 2) || '/' || SUBSTRING(E5.E5_DATA, 1, 4) AS DATA_MOV, "
	cQueryX += "	E5.E5_VALOR AS VALOR_MOV, "
	cQueryX += "	E5.E5_BANCO AS BANCO_MOV, "
	cQueryX += "	E5.E5_AGENCIA AS AGENCIA_MOV, "
	cQueryX += "	E5.E5_CONTA AS CONTA_MOV, "
	cQueryX += "	E5.E5_DOCUMEN AS DOC_MOV, "
	cQueryX += "	E5.E5_HISTOR AS HISTORICO, "
	cQueryX += "	E5.E5_MOTBX AS MOTV_BAIXA "
	cQueryX += "FROM "
	cQueryX += "	" + RetSqlName("SE5") + " E5"
	cQueryX += "WHERE "
	cQueryX += "	E5.E5_FILORIG = '" + cFil + "' "
	cQueryX += "	AND E5.E5_PREFIXO = '" + cPrefix + "' "
	cQueryX += "	AND E5.E5_NUMERO = '" + cDoc + "' "
	cQueryX += "	AND E5.E5_PARCELA = '" + cParcel + "' "
	cQueryX += "	AND E5.E5_TIPO = 'NF' "
	cQueryX += "	AND E5.E5_CLIENTE = '" + cCodCli + "' "
	cQueryX += "	AND E5.E5_LOJA = '" + cLoja + "' "
	cQueryX += "	AND E5.D_E_L_E_T_ = '' "
	cQueryX += "ORDER BY "
	cQueryX += "	DATA_MOV; "

	If Select(cAliasE5) > 0
		DbSelectArea(cAliasE5)
		(cAliasE5)->(dbCloseArea())
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQueryX)), cAliasE5, .F., .T.)
return



/*/{Protheus.doc} printD2
	Funcao que imprime a Section com dados do faturamento, dados da tabela SD2
	@type  Static Function
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
	@type Static Function
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

	cQueryX += "SELECT "
	cQueryX += "	D2.R_E_C_N_O_ AS D2_REC, "
	cQueryX += "	D2.D2_FILIAL, "
	cQueryX += "	D2.D2_CLIENTE, "
	cQueryX += "	D2.D2_LOJA, "
	cQueryX += "	D2.D2_SERIE AS SERIE, "
	cQueryX += "	D2.D2_ITEM AS ITEM, "
	cQueryX += "	D2.D2_COD AS PROD_COD, "
	cQueryX += "	B1.B1_DESC AS PROD_DESCRI, "
	cQueryX += "	D2.D2_QUANT AS QUANTIDADE, "
	cQueryX += "	D2.D2_UM AS UNIDADE, "
	cQueryX += "	D2.D2_PRCVEN AS PRC_UNIT, "
	cQueryX += "	D2.D2_TOTAL AS PRC_ITEM, "
	cQueryX += "	D2.D2_QUANT * D2.D2_PRCVEN AS MULTIPLI_OK "
	cQueryX += "FROM "
	cQueryX += "	" + RetSqlName("SD2") + " D2 "
	cQueryX += "	INNER JOIN "
	cQueryX += "		" + RetSqlName("SB1") + " B1 "
	cQueryX += "		ON D2.D2_COD = B1.B1_COD "
	cQueryX += "		AND B1.D_E_L_E_T_ = '' "
	cQueryX += "WHERE "
	cQueryX += "	D2.D2_DOC = '" + cDoc + "'"
	cQueryX += "	AND D2.D2_FILIAL = '" + cFil + "' "
	cQueryX += "	AND D2.D2_CLIENTE = '" + cCodCli + "' "
	cQueryX += "	AND D2.D2_LOJA = '" + cLoja + "'"
	cQueryX += "	AND D2.D_E_L_E_T_ = '' "
	cQueryX += "ORDER BY "
	cQueryX += "	ITEM; "

	If Select(cAliasD2) > 0
		DbSelectArea(cAliasD2)
		(cAliasD2)->(dbCloseArea())
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQueryX)), cAliasD2, .F., .T.)
return

/*/{Protheus.doc} montaE1
	Funcao que monta o cAliasE1
	@type Static Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
/*/
static function montaE1()
	local cQuery1			:= ""
	local cFil				:= ""
	local cListaClientes	:= ""

	cFil := "'FG01', 'FG02'"
	cListaClientes := "'084500310-0001', '000516169-0001', '004142810-0001', '103333160-0001', '445932640-0001', '220554560-0001', '204771690-0001', '005189690-0001', '042827500-0001'"
	cListaSituacoes := "'0', '1', '2', '3', '4', '5', '6', '7', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'"

	cQuery1 := montaQueryE1(cFil, cListaClientes, cListaSituacoes)
	If Select(cAliasE1) > 0
		DbSelectArea(cAliasE1)
		(cAliasE1)->(dbCloseArea())
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery1)), cAliasE1, .F., .T.)
	dbSelectArea(cAliasE1)
	If (cAliasE1)->(Eof())
		msgAlert("Nao existem dados no alias " + cAliasE1, "UFINR85.PRW")
	endIf
return

/*/{Protheus.doc} montaQueryE1
	Funcao que monta a query que será usada para montar o cAliasE1
	@type  Static Function
	@author Julio Carvalho Barberino
	@since 21/08/2025
	@version 0
	@param cFil, c, Filial
	@param cListaClientes, c, Lista com R_E_C_N_O_ de clientes
	@param cListaSituacoes, c, Lista com R_E_C_N_O_ de tipos de situacoes
	@param cDtVenc0, c, data de vencimento inicial do intervalo
	@param cDtVenc1, c, data de vencimento final do intervalo
	@param cDtEmis0, c, data de emissao inicio do intervalo
	@param cDtEmis1, c, data de emissao final do intervalo
/*/
static function montaQueryE1(cFil, cListaClientes, cListaSituacoes, cDtVenc0, cDtVenc1, cDtEmis0, cDtEmis1)
	local cQueryX	:= ""
	local cWhere1	:= ""
	local cOrder1	:= ""

	cWhere1 += "WHERE "
	cWhere1 += "	E1.E1_TIPO = 'NF' "
	#IFNDEF SEM_PARAMETROS
		cWhere1 += "			AND E1.E1_FILORIG IN (" + cFil + ") "
		cWhere1 += "			AND E1.E1_CLIENTE || '-' || E1.E1_LOJA IN (" + cListaClientes + ") "
		cWhere1 += "			AND E1.E1_SITUACA IN (" + cListaSituacoes + ") ".
		cWhere1 += "			AND E1.E1_VENCTO BETWEEN '" + cDtVenc0 + "' AND '" + cDtVenc1 + "' "
		cWhere1 += "			AND E1.E1_EMISSAO BETWEEN '" + cDtEmis0 + "' AND '" + cDtEmis1 + "' "
	#ENDIF
	cWhere1 += "			AND E1.E1_SALDO <> 0 "
	cWhere1 += "			AND E1.D_E_L_E_T_ = '' "

	cOrder1 += "ORDER BY "
	if cTipG == "1"
		cOrder1 += "	CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
	elseIf cTipG == "2"
		cOrder1 += "	VENCIMENTO, CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
	elseIf cTipG == "3"
		cOrder1 += "	EMISSAO, CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
	elseIf cTipG == "10"
		cOrder1 += "	BANCO, CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
	elseIf cTipG == "11"
		cOrder1 += "	CONTRATO, CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
	elseIf cTipG == "12"
		cOrder1 += "	VEND_GER, CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
	elseIf cTipG == "13"
		cOrder1 += "	VEND_REGI, CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
	elseIf cTipG == "14"
		cOrder1 += "	VEND_NOME, CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
	else
		msgAlert("falha no tipo de agrupamento", "UFINR85.PRW")
		cOrder1 += "	CLI_NOME, LOJA, DOCUMENTO, PARCELA; "
		return
	endIf

	cQueryX += "SELECT "
	cQueryX += "	E1.*, "
	cQueryX += "	CASE "
	cQueryX += "		WHEN ATRASO > 0 THEN SALDO ELSE 0 "
	cQueryX += "	END AS VL_VENCIDO, "
	cQueryX += "	CASE "
	cQueryX += "		WHEN ATRASO > 0 THEN ROUND(SALDO * (TX_JUROS / 100) * (ATRASO / 30.5), 2) + SALDO ELSE 0 "
	cQueryX += "	END AS VL_CORRIG, "
	cQueryX += "	CASE "
	cQueryX += "		WHEN ATRASO > 0 THEN ROUND(SALDO * (TX_JUROS / 100) * (ATRASO / 30.5), 2) ELSE 0 "
	cQueryX += "	END AS VL_JUROS "
	cQueryX += "FROM "
	cQueryX += "	( "
	cQueryX += "	SELECT "
	cQueryX += "		E1.R_E_C_N_O_ AS E1_REC, "
	cQueryX += "		E1.E1_FILORIG AS FILIAL, "
	cQueryX += "		A1.A1_COD AS CLI_COD, "
	cQueryX += "		A1.A1_LOJA AS LOJA, "
	cQueryX += "		A1.A1_NOME AS CLI_NOME, "
	cQueryX += "		E1.E1_PREFIXO AS PREFIXO, "
	cQueryX += "		E1.E1_NUM AS DOCUMENTO, "
	cQueryX += "		E1.E1_PARCELA AS PARCELA, "
	cQueryX += "		E1.E1_TIPO AS TIPO, "
	cQueryX += "		E1.E1_NATUREZ AS NATUREZA, "
	cQueryX += "		SUBSTRING(E1.E1_EMISSAO, 7, 2) || '/' || SUBSTRING(E1.E1_EMISSAO, 5, 2) || '/' || SUBSTRING(E1.E1_EMISSAO, 1, 4) AS EMISSAO, "
	cQueryX += "		SUBSTRING(E1.E1_VENCTO, 7, 2) || '/' || SUBSTRING(E1.E1_VENCTO, 5, 2) || '/' || SUBSTRING(E1.E1_VENCTO, 1, 4) AS VENCIMENTO, "
	cQueryX += "		SUBSTRING(E1.E1_VENCREA, 7, 2) || '/' || SUBSTRING(E1.E1_VENCREA, 5, 2) || '/' || SUBSTRING(E1.E1_VENCREA, 1, 4) AS VENC_REAL, "
	cQueryX += "		E1_NUMBCO AS BANCO, "
	cQueryX += "		E1.E1_SITUACA AS ST, "
	cQueryX += "		E1.E1_CONTRAT AS CONTRATO, "
	cQueryX += "		E1.E1_VALOR AS VL_ORIG, "
	cQueryX += "		1.5 AS TX_JUROS, "
	cQueryX += "		DATEDIFF "
	cQueryX += "		( "
	cQueryX += "			DAY, "
	cQueryX += "			SUBSTRING(E1.E1_VENCREA, 1, 4) || '/' || SUBSTRING(E1.E1_VENCREA, 5, 2) || '/' || SUBSTRING(E1.E1_VENCREA, 7, 2), "
	cQueryX += "			GETDATE() "
	cQueryX += "		) AS ATRASO, "
	cQueryX += "		E1.E1_SALDO AS SALDO, "
	cQueryX += "		E1.E1_NUMBCO AS NUMBCO, "
	cQueryX += "		E1.E1_BAIXA AS ULTIMA_BAIXA, "
	cQueryX += "		A3.A3_COD AS VEND_COD, "
	cQueryX += "		A3.A3_NOME AS VEND_NOME, "
	cQueryX += "		A3.A3_REGIAO AS VEND_REGI, "
	cQueryX += "		A3.A3_GEREN AS VEND_GER "
	cQueryX += "	FROM "
	cQueryX += "		" + RetSqlName("SE1") + " E1 "
	cQueryX += "		INNER JOIN "
	cQueryX += "			" + RetSqlName("SA1") + " A1 "
	cQueryX += "			ON E1.E1_CLIENTE = A1.A1_COD "
	cQueryX += "			AND E1.E1_LOJA = A1.A1_LOJA "
	cQueryX += "			AND A1.D_E_L_E_T_ = '' "
	cQueryX += "		LEFT JOIN "
	cQueryX += "			" + RetSqlName("SA3") + " A3 "
	cQueryX += "			ON E1.E1_VEND1 = A3.A3_COD "
	cQueryX += "			AND A3.D_E_L_E_T_ = '' "
	cQueryX += cWhere1
	cQueryX += "	) E1 "
	cQueryX += cOrder1

return cQueryX

/*
	https://terminaldeinformacao.com/2024/02/27/abrindo-uma-tela-para-marcacao-de-registros-com-a-f_opcoes-maratona-advpl-e-tl-261/
	https://terminaldeinformacao.com/knowledgebase/parambox/

	Verificar com consultor funcional:
		Se marcado como não, o sistema utilizara as taxas de juros e multa padrão. Onde estão essses padrões
		Juros multa e antecipação. O que é antecipação?
		Agrupamentos "E" ou "OU" ??
		Juros mensal ou diário?
		Agrupamento por contrato?
*/
