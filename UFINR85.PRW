#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"

#DEFINE SEM_PARAMETROS

user function FINR85()
	local oReport

	private cAliasE1	:= "UFINR85E1"
	private cAliasD2	:= "UFINR85D2"

	montaE1E5()

	oReport := fReportDef()
	oReport:PrintDialog()

	DbCloseArea()
return

static function fReportDef()
	local oReport
	local oSecE1E5	:= Nil
	local oSecD2	:= Nil

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
	oReport:SetLineHeight(50)
	oReport:nFontBody := 12

	//Criando a secao de dados da E1 e E5
	oSecE1E5	:= TRSection():New(;
		oReport /*oParent*/, ;
		"SecaoE1E5" /*cTitle*/, ;
		{cAliasE1} /*uTable*/, /*aOrder*/, /*lLoadCells*/, /*lLoadOrder*/, /*uTotalText*/, /*lTotalInLine*/, /*lHeaderPage*/, /*lHeaderBreak*/, /*lPageBreak*/, /*lLineBreak*/, /*nLeftMargin*/, /*lLineStyle*/, /*nColSpace*/, /*lAutoSize*/, /*cCharSeparator*/, /*nLinesBefore*/, /*nCols*/, /*nClrBack*/, /*nClrFore*/, /*nPercentage*/)
	//Criando a secao de dados da D2
	oSecD2	:= TRSection():New(oReport, "SecaoE1E5", {cAliasE1}, , , , , , , , , , , , , , , , , , , )

	//Colunas do relatorio E1E5
	TRCell():New(;
		oSecE1E5 /*oParent*/, ;
		"CLI_COD" /*cName*/, ;
		cAliasE1 /*cAliasE1*/, ;
		"Cod-Cli" /*cTitle*/, /*cPicture*/, ;
		10 /*nSize*/, /*lPixel*/, /*bBlock*/, ;
		"LEFT" /*cAlign*/, /*lLineBreak*/, ;
		"LEFT" /*lLineBreak*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, ;
		.T. /*lBold*/)
	TRCell():New(oSecE1E5, "LOJA", cAliasE1, "Loja-Cli", , 5, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "CLI_NOME", cAliasE1, "Cliente", , 40, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "PREFIXO", cAliasE1, "Prf", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "DOCUMENTO", cAliasE1, "Documento", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "PARCELA", cAliasE1, "Parc", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "TIPO", cAliasE1, "Tp", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "NATUREZA", cAliasE1, "Natureza", , 11, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "EMISSAO", cAliasE1, "Dt Emissao", , 9, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "VENCIMENTO", cAliasE1, "Venc", , 9, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "VENC_REAL", cAliasE1, "VencReal", , 9, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "BANCO", cAliasE1, "Bco", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "ST", cAliasE1, "St", , 3, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "VALOR", cAliasE1, "Val-Orig", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "SALDO", cAliasE1, "Val-Atual", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "NUMBCO", cAliasE1, "NumBco", , 16, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "VL_JUROS", cAliasE1, "Val-Juros", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "ATRASO", cAliasE1, "Atraso", , 6, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "HISTORICO", cAliasE1, "Historico", , 15, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecE1E5, "SALDO", cAliasE1, "Saldo", , 10, , , "LEFT" , , "LEFT" , , , , , , .T.)

	// Colunas do relatorio D2
	TRCell():New(oSecD2, "ITEM", cAliasE1, "Item", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecD2, "PROD_COD", cAliasE1, "Cod", , 12, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecD2, "PROD_DESCRI", cAliasE1, "Produto", , 40, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecD2, "QUANTIDADE", cAliasE1, "Quant", , 6, , , "LEFT" , , "LEFT" , , , , , , .T.)
	TRCell():New(oSecD2, "UNIDADE", cAliasE1, "Un", , 4, , , "LEFT" , , "LEFT" , , , , , , .T.)

	//Quebras do relatorio
	oBreak := TRBreak():New(oSecE1E5, oSecE1E5:Cell("CLI_COD"), {||"Total da Quebra"}, .F.)



return oReport

static function fGoPrint(oReport)
	//local cPerg				:= "FIN130"
	local nAtual			:= 0
	local nTotal			:= 0
	local lAliasE1Vazio		:= .T.
	local cFilialControle	:= ""
	local cPrefixControle	:= ""
	local cDocumeControle	:= ""
	local cLojaControle		:= ""
	private oSecE1E5
	private oSecD2

	//Pegando as secoes do relatorio
	oSecE1E5 := oReport:Section(1)
	oSecD2 := oReport:Section(2)

	Count to nTotal
	oReport:SetMeter(nTotal)

	dbGoTop()
	cFilialControle := (cAliasE1)->FILIAL
	cPrefixControle := (cAliasE1)->PREFIXO
	cDocumeControle := (cAliasE1)->DOCUMENTO
	cCodCliControle := (cAliasE1)->CLI_COD
	cLojaControle	:= (cAliasE1)->LOJA
	// Enquanto houver dados
	oSecE1E5:Init()
	while !(cAliasE1)->(Eof())
		nAtual++
		lAliasE1Vazio := .F. // Indica que houve pelo menos um registro no alias cAliasE1
		oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		oReport:IncMeter()
		if (cFilialControle = (cAliasE1)->FILIAL .and. cPrefixControle = (cAliasE1)->PREFIXO .and. cDocumeControle = (cAliasE1)->DOCUMENTO) // Mesmo titulo
			oSecE1E5:PrintLine()
			(cAliasE1)->(dbSkip())
		else // Outro titulo
			oSecE1E5:Finish()
			printD2(cFilialControle, cDocumeControle, cCodCliControle, cLojaControle)
			DbSelectArea(cAliasE1)
			cFilialControle := (cAliasE1)->FILIAL
			cPrefixControle := (cAliasE1)->PREFIXO
			cDocumeControle := (cAliasE1)->DOCUMENTO
			cCodCliControle := (cAliasE1)->CLI_COD
			cLojaControle	:= (cAliasE1)->LOJA
			oSecE1E5:Init()
		end
	endDo
	oSecE1E5:Finish()
	if !lAliasE1Vazio
		printD2(cFilialControle, cDocumeControle, cCodCliControle, cLojaControle)
	else
		msgAlert("Nao existem dados no alias " + cAliasE1, "UFINR85.PRW")
	endIf
return

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
	else
		msgAlert("Nao existem dados no alias " + cAliasD2, "UFINR85.PRW")
	endIf
return

static function montaE1E5()
	local cQuery1			:= ""
	local cFil				:= ""
	local cListaClientes	:= ""

	cFil := "'FG01', 'FG02'"
	cListaClientes := "'084500310-0001', '000516169-0001', '004142810-0001', '103333160-0001', '445932640-0001', '220554560-0001', '204771690-0001', '005189690-0001', '042827500-0001'"
	cListaSituacoes := "'0', '1', '2', '3', '4', '5', '6', '7', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'"

	cQuery1 := montaQueryE1E5(cFil, cListaClientes, cListaSituacoes)
	If Select(cAliasE1) > 0
		DbSelectArea(cAliasE1)
		DbCloseArea()
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery1)), cAliasE1, .F., .T.)
	dbSelectArea(cAliasE1)
	If (cAliasE1)->(Eof())
		msgAlert("Nao existem dados no alias " + cAliasE1, "UFINR85.PRW")
	endIf
return


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
	cQueryX += "	AND D2.D_E_L_E_T_ = ''; "

	If Select(cAliasD2) > 0
		DbSelectArea(cAliasD2)
		DbCloseArea()
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQueryX)), cAliasD2, .F., .T.)
return

static function montaQueryE1E5(cFil, cListaClientes, cListaSituacoes)
	local cQueryX	:= ""
	local cWhere1	:= ""

	cWhere1 += "WHERE "
	cWhere1 += "	E1.E1_TIPO = 'NF' "
	#IFNDEF SEM_PARAMETROS
		cWhere1 += "			AND E1.E1_FILORIG IN (" + cFil + ") "
		cWhere1 += "			AND E1.E1_CLIENTE || '-' || E1.E1_LOJA IN (" + cListaClientes + ") "
		cWhere1 += "			AND E1.E1_SITUACA IN (" + cListaSituacoes + ") "
	#ENDIF
	cWhere1 += "			AND E1.E1_SALDO <> 0 "
	cWhere1 += "			AND E1.D_E_L_E_T_ = '' "

	cQueryX += "SELECT "
	cQueryX += "	E1.R_E_C_N_O_ AS E1_REC, "
	cQueryX += "	E5.R_E_C_N_O_ AS E5_REC, "
	cQueryX += "	E1.E1_FILORIG AS FILIAL, "
	cQueryX += "	A1.A1_COD AS CLI_COD, "
	cQueryX += "	A1.A1_LOJA AS LOJA, "
	cQueryX += "	A1.A1_NOME AS CLI_NOME, "
	cQueryX += "	E1.E1_PREFIXO AS PREFIXO, "
	cQueryX += "	E1.E1_NUM AS DOCUMENTO, "
	cQueryX += "	E1.E1_PARCELA AS PARCELA, "
	cQueryX += "	E1.E1_TIPO AS TIPO, "
	cQueryX += "	E1.E1_NATUREZ AS NATUREZA, "
	cQueryX += "	E1.E1_EMISSAO AS EMISSAO, "
	cQueryX += "	E1.E1_VENCTO AS VENCIMENTO, "
	cQueryX += "	E1.E1_VENCREA AS VENC_REAL, "
	cQueryX += "	E1_NUMBCO AS BANCO, "
	cQueryX += "	E1.E1_SITUACA AS ST, "
	cQueryX += "	E1.E1_VALOR AS VALOR, "
	cQueryX += "	'' AS VL_ORIG, "
	cQueryX += "	'' AS VL_NOMINAL, "
	cQueryX += "	'' AS VL_CORRIG, "
	cQueryX += "	'' AS VL_VENCIDO, "
	cQueryX += "	'' AS VL_JUROS, "
	cQueryX += "	'' AS ATRASO, "
	cQueryX += "	CASE "
	cQueryX += "		WHEN E5.R_E_C_N_O_ <> 0 THEN E5.E5_HISTOR ELSE E1.E1_HIST "
	cQueryX += "	END AS HISTORICO, "
	cQueryX += "	E1.E1_SALDO AS SALDO, "
	cQueryX += "	E1.E1_NUMBCO AS NUMBCO, "
	cQueryX += "	E1.E1_BAIXA AS ULTIMA_BAIXA, "
	cQueryX += "	E5.E5_DATA AS DATA_MOV, "
	cQueryX += "	E5.E5_VALOR AS VALOR_MOV, "
	cQueryX += "	E5.E5_BANCO AS BANCO_MOV, "
	cQueryX += "	E5.E5_AGENCIA AS AGENCIA_MOV, "
	cQueryX += "	E5.E5_CONTA AS CONTA_MOV, "
	cQueryX += "	E5.E5_DOCUMEN AS DOC_MOV, "
	cQueryX += "	E5.E5_MOTBX AS MOTV_BAIXA, "
	cQueryX += "	'' AS PROD_COD, "
	cQueryX += "	A3.A3_COD AS VEND_COD, "
	cQueryX += "	A3.A3_NOME AS VEND_NOME, "
	cQueryX += "	A3.A3_REGIAO AS VEND_REGI, "
	cQueryX += "	A3.A3_GEREN AS VEND_GER "
	cQueryX += "FROM "
	cQueryX += "	" + RetSqlName("SE1") + " E1 "
	cQueryX += "	INNER JOIN "
	cQueryX += "		" + RetSqlName("SA1") + " A1 "
	cQueryX += "		ON E1.E1_CLIENTE = A1.A1_COD "
	cQueryX += "		AND E1.E1_LOJA = A1.A1_LOJA "
	cQueryX += "		AND A1.D_E_L_E_T_ = '' "
	cQueryX += "	LEFT JOIN "
	cQueryX += "		" + RetSqlName("SA3") + " A3 "
	cQueryX += "		ON E1.E1_VEND1 = A3.A3_COD "
	cQueryX += "		AND A3.D_E_L_E_T_ = '' "
	cQueryX += "	LEFT JOIN "
	cQueryX += "		" + RetSqlName("SE5") + " E5 "
	cQueryX += "		ON E1.E1_FILORIG = E5.E5_FILORIG "
	cQueryX += "		AND E1.E1_PREFIXO = E5.E5_PREFIXO "
	cQueryX += "		AND E1.E1_NUM = E5.E5_NUMERO "
	cQueryX += "		AND E1.E1_PARCELA = E5.E5_PARCELA "
	cQueryX += "		AND E1.E1_TIPO = E5.E5_TIPO "
	cQueryX += "		AND E1.E1_CLIENTE = E5.E5_CLIENTE "
	cQueryX += "		AND E1.E1_LOJA = E5.E5_LOJA "
	cQueryX += "		AND E1.E1_FILIAL = E5.E5_FILIAL "
	cQueryX += "		AND E5.D_E_L_E_T_ = '' "
	cQueryX += cWhere1
	cQueryX += "ORDER BY "
	cQueryX += "	CLI_NOME, LOJA, DOCUMENTO, PARCELA, DATA_MOV; "

return cQueryX
