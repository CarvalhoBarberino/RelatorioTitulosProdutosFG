#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"

#DEFINE SEM_PARAMETROS

user function FINR85()
	local oReport

	private cAlias	:= "UFINR85"




	oReport := fReportDef()
	oReport:PrintDialog()




	DbCloseArea()
return

static function fReportDef()
	local oReport
	local oSecCli := Nil

	//Criacao do componente de impressao
	oReport	:= TReport():New(;
		cAlias /*cReport*/, ;
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

	//Criando a secao de dados
	oSecCli	:= TRSection():New(;
		oReport /*oParent*/, ;
		"Secao_1" /*cTitle*/, ;
		{cAlias} /*uTable*/, /*aOrder*/, /*lLoadCells*/, /*lLoadOrder*/, /*uTotalText*/, /*lTotalInLine*/, /*lHeaderPage*/, /*lHeaderBreak*/, /*lPageBreak*/, /*lLineBreak*/, /*nLeftMargin*/, /*lLineStyle*/, /*nColSpace*/, /*lAutoSize*/, /*cCharSeparator*/, /*nLinesBefore*/, /*nCols*/, /*nClrBack*/, /*nClrFore*/, /*nPercentage*/)

	//Colunas do relatorio
	TRCell():New(;
		oSecCli /*oParent*/, ;
		"CLI_COD" /*cName*/, ;
		cAlias /*cAlias*/, ;
		"Cod-Cli" /*cTitle*/, /*cPicture*/, ;
		15 /*nSize*/, /*lPixel*/, /*bBlock*/, ;
		"LEFT" /*cAlign*/, /*lLineBreak*/, ;
		"LEFT" /*lLineBreak*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, ;
		.T. /*lBold*/)
	TRCell():New(;
		oSecCli /*oParent*/, ;
		"LOJA" /*cName*/, ;
		cAlias /*cAlias*/, ;
		"Loja-Cli" /*cTitle*/, /*cPicture*/, ;
		15 /*nSize*/, /*lPixel*/, /*bBlock*/, ;
		"LEFT" /*cAlign*/, /*lLineBreak*/, ;
		"LEFT" /*lLineBreak*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, ;
		.T. /*lBold*/)
	TRCell():New(;
		oSecCli /*oParent*/, ;
		"DOCUMENTO" /*cName*/, ;
		cAlias /*cAlias*/, ;
		"Numero" /*cTitle*/, /*cPicture*/, ;
		15 /*nSize*/, /*lPixel*/, /*bBlock*/, ;
		"LEFT" /*cAlign*/, /*lLineBreak*/, ;
		"LEFT" /*lLineBreak*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, ;
		.T. /*lBold*/)
	TRCell():New(;
		oSecCli /*oParent*/, ;
		"PARCELA" /*cName*/, ;
		cAlias /*cAlias*/, ;
		"Parc" /*cTitle*/, /*cPicture*/, ;
		15 /*nSize*/, /*lPixel*/, /*bBlock*/, ;
		"LEFT" /*cAlign*/, /*lLineBreak*/, ;
		"LEFT" /*lLineBreak*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, ;
		.T. /*lBold*/)
	TRCell():New(;
		oSecCli /*oParent*/, ;
		"ITEM" /*cName*/, ;
		cAlias /*cAlias*/, ;
		"Item" /*cTitle*/, /*cPicture*/, ;
		15 /*nSize*/, /*lPixel*/, /*bBlock*/, ;
		"LEFT" /*cAlign*/, /*lLineBreak*/, ;
		"LEFT" /*lLineBreak*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, ;
		.T. /*lBold*/)
	TRCell():New(;
		oSecCli /*oParent*/, ;
		"DATA_MOV" /*cName*/, ;
		cAlias /*cAlias*/, ;
		"DataMov" /*cTitle*/, /*cPicture*/, ;
		15 /*nSize*/, /*lPixel*/, /*bBlock*/, ;
		"LEFT" /*cAlign*/, /*lLineBreak*/, ;
		"LEFT" /*lLineBreak*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, ;
		.T. /*lBold*/)

	//Quebras do relatorio
	oBreak := TRBreak():New(oSecCli, oSecCli:Cell("CLI_COD"), {||"Total da Quebra"}, .F.)

	

return oReport

static function fGoPrint(oReport)
	local cQuery1			:= ""
	local cFil				:= ""
	local cListaClientes	:= ""
	//local cPerg				:= "FIN130"
	local nAtual			:= 0
	local nTotal			:= 0
	local oSectDad

	//Pegando as secoes do relatorio
	oSectDad := oReport:Section(1)

	cFil := "'FG01', 'FG02'"
	cListaClientes := "'084500310-0001', '000516169-0001', '004142810-0001', '103333160-0001', '445932640-0001', '220554560-0001', '204771690-0001', '005189690-0001', '042827500-0001'"
	cListaSituacoes := "'0', '1', '2', '3', '4', '5', '6', '7', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'"

	cQuery1 := montaQuery(cFil, cListaClientes, cListaSituacoes)
	If Select(cAlias) > 0
		DbSelectArea(cAlias)
		DbCloseArea()
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery1), cAlias, .F., .T.)
	dbSelectArea(cAlias)
	If (cAlias)->(Eof())
		msgAlert("Não existem dados no alias " + cAlias, "UFINR85.PRW")
		return
	endIf

	Count to nTotal
	oReport:SetMeter(nTotal)
	//Enquanto houver dados
	oSectDad:Init()
	dbGoTop()
	while !(cAlias)->(Eof())

		nAtual++
		oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		oReport:IncMeter()

		//Imprimindo a linha atual
		oSectDad:PrintLine()

		(cAlias)->(dbSkip())

	endDo

	oSectDad:Finish()
	(cAlias)->(DbCloseArea())

return

static function montaQuery(cFil, cListaClientes, cListaSituacoes)
	local cQueryX	:= ""
	local cWhere1	:= ""

	cWhere1 += "		WHERE "
	cWhere1 += "			E1.E1_TIPO = 'NF' "
	#IFNDEF SEM_PARAMETROS
		cWhere1 += "			AND E1.E1_FILORIG IN (" + cFil + ") "
		cWhere1 += "			AND E1.E1_CLIENTE || '-' || E1.E1_LOJA IN (" + cListaClientes + ") "
		cWhere1 += "			AND E1.E1_SITUACA IN (" + cListaSituacoes + ") "
	#ENDIF
	cWhere1 += "			AND E1.E1_SALDO <> 0 "
	cWhere1 += "			AND E1.D_E_L_E_T_ = '' "

	cQueryX += "SELECT "
	cQueryX += "	REL.* "
	cQueryX += "FROM "
	cQueryX += "	(SELECT "
	cQueryX += "		* "
	cQueryX += "	FROM "
	cQueryX += "		(SELECT "
	cQueryX += "			E1.R_E_C_N_O_ AS E1_REC, "
	cQueryX += "			E5.R_E_C_N_O_ AS E5_REC, "
	cQueryX += "			0 AS D2_REC, "
	cQueryX += "			E1.E1_FILORIG AS FILIAL, "
	cQueryX += "			A1.A1_COD AS CLI_COD, "
	cQueryX += "			A1.A1_LOJA AS LOJA, "
	cQueryX += "			A1.A1_NOME AS CLI_NOME, "
	cQueryX += "			E1.E1_PREFIXO AS PREFIXO, "
	cQueryX += "			'' AS SERIE, "
	cQueryX += "			E1.E1_NUM AS DOCUMENTO, "
	cQueryX += "			E1.E1_PARCELA AS PARCELA, "
	cQueryX += "			'' AS ITEM, "
	cQueryX += "			E1.E1_TIPO AS TIPO, "
	cQueryX += "			E1.E1_NATUREZ AS NATUREZA, "
	cQueryX += "			E1.E1_EMISSAO AS EMISSAO, "
	cQueryX += "			E1.E1_VENCTO AS VENCIMENTO, "
	cQueryX += "			E1.E1_VENCREA AS VENC_REAL, "
	cQueryX += "			E1_NUMBCO AS BANCO, "
	cQueryX += "			E1.E1_SITUACA AS ST, "
	cQueryX += "			E1.E1_VALOR AS VALOR, "
	cQueryX += "			'' AS VL_ORIG, "
	cQueryX += "			'' AS VL_NOMINAL, "
	cQueryX += "			'' AS VL_CORRIG, "
	cQueryX += "			'' AS VL_VENCIDO, "
	cQueryX += "			'' AS VL_JUROS, "
	cQueryX += "			'' AS ATRASO, "
	cQueryX += "			E1.E1_SALDO AS SALDO, "
	cQueryX += "			E1.E1_BAIXA AS ULTIMA_BAIXA, "
	cQueryX += "			E5.E5_DATA AS DATA_MOV, "
	cQueryX += "			E5.E5_VALOR AS VALOR_MOV, "
	cQueryX += "			E5.E5_BANCO AS BANCO_MOV, "
	cQueryX += "			E5.E5_AGENCIA AS AGENCIA_MOV, "
	cQueryX += "			E5.E5_CONTA AS CONTA_MOV, "
	cQueryX += "			E5.E5_DOCUMEN AS DOC_MOV, "
	cQueryX += "			E5.E5_MOTBX AS MOTV_BAIXA, "
	cQueryX += "			'' AS PROD_COD, "
	cQueryX += "			'' AS PROD_DESCRI, "
	cQueryX += "			0 AS QUANTIDADE, "
	cQueryX += "			'' AS UNIDADE, "
	cQueryX += "			0 AS PRC_UNIT, "
	cQueryX += "			0 AS PRC_ITEM, "
	cQueryX += "			'' AS MULTIPLI_OK, "
	cQueryX += "			A3.A3_COD AS VEND_COD, "
	cQueryX += "			A3.A3_NOME AS VEND_NOME, "
	cQueryX += "			A3.A3_REGIAO AS VEND_REGI, "
	cQueryX += "			A3.A3_GEREN AS VEND_GER "
	cQueryX += "		FROM "
	cQueryX += "			" + RetSqlName("SE1") + " E1 "
	cQueryX += "			INNER JOIN "
	cQueryX += "				" + RetSqlName("SA1") + " A1 "
	cQueryX += "				ON E1.E1_CLIENTE = A1.A1_COD "
	cQueryX += "				AND E1.E1_LOJA = A1.A1_LOJA "
	cQueryX += "				AND A1.D_E_L_E_T_ = '' "
	cQueryX += "			LEFT JOIN "
	cQueryX += "				" + RetSqlName("SA3") + " A3 "
	cQueryX += "				ON E1.E1_VEND1 = A3.A3_COD "
	cQueryX += "				AND A3.D_E_L_E_T_ = '' "
	cQueryX += "			LEFT JOIN "
	cQueryX += "				" + RetSqlName("SE5") + " E5 "
	cQueryX += "				ON E1.E1_FILORIG = E5.E5_FILORIG "
	cQueryX += "				AND E1.E1_PREFIXO = E5.E5_PREFIXO "
	cQueryX += "				AND E1.E1_NUM = E5.E5_NUMERO "
	cQueryX += "				AND E1.E1_PARCELA = E5.E5_PARCELA "
	cQueryX += "				AND E1.E1_TIPO = E5.E5_TIPO "
	cQueryX += "				AND E1.E1_CLIENTE = E5.E5_CLIENTE "
	cQueryX += "				AND E1.E1_LOJA = E5.E5_LOJA "
	cQueryX += "				AND E1.E1_FILIAL = E5.E5_FILIAL "
	cQueryX += "				AND E5.D_E_L_E_T_ = '' "
	cQueryX += cWhere1
	cQueryX += "		) RELE5 "
	cQueryX += "	UNION "
	cQueryX += "	SELECT "
	cQueryX += "		* "
	cQueryX += "	FROM "
	cQueryX += "		(SELECT "
	cQueryX += "			E1.R_E_C_N_O_ AS E1_REC, "
	cQueryX += "			0 AS E5_REC, "
	cQueryX += "			D2.R_E_C_N_O_ AS D2_REC, "
	cQueryX += "			E1.E1_FILORIG AS FILIAL, "
	cQueryX += "			A1.A1_COD AS CLI_COD, "
	cQueryX += "			A1.A1_LOJA AS LOJA, "
	cQueryX += "			A1.A1_NOME AS CLI_NOME, "
	cQueryX += "			E1.E1_PREFIXO AS PREFIXO, "
	cQueryX += "			D2.D2_SERIE AS SERIE, "
	cQueryX += "			E1.E1_NUM AS DOCUMENTO, "
	cQueryX += "			E1.E1_PARCELA AS PARCELA, "
	cQueryX += "			D2.D2_ITEM AS ITEM, "
	cQueryX += "			E1.E1_TIPO AS TIPO, "
	cQueryX += "			E1.E1_NATUREZ AS NATUREZA, "
	cQueryX += "			E1.E1_EMISSAO AS EMISSAO, "
	cQueryX += "			E1.E1_VENCTO AS VENCIMENTO, "
	cQueryX += "			E1.E1_VENCREA AS VENC_REAL, "
	cQueryX += "			E1_NUMBCO AS BANCO, "
	cQueryX += "			E1.E1_SITUACA AS ST, "
	cQueryX += "			0 AS VALOR, "
	cQueryX += "			'' AS VL_ORIG, "
	cQueryX += "			'' AS VL_NOMINAL, "
	cQueryX += "			'' AS VL_CORRIG, "
	cQueryX += "			'' AS VL_VENCIDO, "
	cQueryX += "			'' AS VL_JUROS, "
	cQueryX += "			'' AS ATRASO, "
	cQueryX += "			0 AS SALDO, "
	cQueryX += "			E1.E1_BAIXA AS ULTIMA_BAIXA, "
	cQueryX += "			'' AS DATA_MOV, "
	cQueryX += "			0 AS VALOR_MOV, "
	cQueryX += "			'' AS BANCO_MOV, "
	cQueryX += "			'' AS AGENCIA_MOV, "
	cQueryX += "			'' AS CONTA_MOV, "
	cQueryX += "			'' AS DOC_MOV, "
	cQueryX += "			'' AS MOTV_BAIXA, "
	cQueryX += "			D2.D2_COD AS PROD_COD, "
	cQueryX += "			B1.B1_DESC AS PROD_DESCRI, "
	cQueryX += "			D2.D2_QUANT AS QUANTIDADE, "
	cQueryX += "			D2.D2_UM AS UNIDADE, "
	cQueryX += "			D2.D2_PRCVEN AS PRC_UNIT, "
	cQueryX += "			D2.D2_TOTAL AS PRC_ITEM, "
	cQueryX += "			CASE "
	cQueryX += "				WHEN "
	cQueryX += "					D2.D2_QUANT * D2.D2_PRCVEN = D2.D2_TOTAL "
	cQueryX += "				THEN "
	cQueryX += "					'ok' "
	cQueryX += "				ELSE "
	cQueryX += "					'ERR' "
	cQueryX += "			END "
	cQueryX += "			AS MULTIPLI_OK, "
	cQueryX += "			'' AS VEND_COD, "
	cQueryX += "			'' AS VEND_NOME, "
	cQueryX += "			'' AS VEND_REGI, "
	cQueryX += "			'' AS VEND_GER "
	cQueryX += "		FROM "
	cQueryX += "			" + RetSqlName("SE1") + " E1 "
	cQueryX += "			INNER JOIN "
	cQueryX += "				" + RetSqlName("SA1") + " A1 "
	cQueryX += "				ON E1.E1_CLIENTE = A1.A1_COD "
	cQueryX += "				AND E1.E1_LOJA = A1.A1_LOJA "
	cQueryX += "				AND A1.D_E_L_E_T_ = '' "
	cQueryX += "			INNER JOIN "
	cQueryX += "				" + RetSqlName("SD2") + " D2 "
	cQueryX += "				ON E1.E1_NUM = D2.D2_DOC "
	cQueryX += "				AND E1.E1_FILORIG = D2.D2_FILIAL "
	cQueryX += "				AND E1.E1_CLIENTE = D2.D2_CLIENTE "
	cQueryX += "				AND D2.D_E_L_E_T_ = '' "
	cQueryX += "			INNER JOIN "
	cQueryX += "				" + RetSqlName("SB1") + " B1 "
	cQueryX += "				ON D2.D2_COD = B1.B1_COD "
	cQueryX += "				AND B1.D_E_L_E_T_ = '' "
	cQueryX += cWhere1
	cQueryX += "		) RELD2 "
	cQueryX += "	) REL "
	cQueryX += "ORDER BY "
	cQueryX += "	CLI_NOME, LOJA, DOCUMENTO, PARCELA, ITEM, DATA_MOV; "

return cQueryX
