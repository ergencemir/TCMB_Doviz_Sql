USE master
GO

DECLARE @URL VARCHAR(8000) 
DECLARE @XML xml
DECLARE @Obj int 
DECLARE @Result int 
DECLARE @HTTPStatus int 
DECLARE @ErrorMsg varchar(MAX)
SET @URL = 'http://www.tcmb.gov.tr/kurlar/today.xml' 
DECLARE @_xml TABLE (
yourXML xml
)

EXEC @Result = sp_OACreate 'MSXML2.XMLHttp', @Obj OUT 

EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @URL, false
EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'
EXEC @Result = sp_OAMethod @Obj, send, NULL, ''
EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT 

INSERT @_xml ( yourXML )
EXEC @Result = sp_OAGetProperty @Obj, 'responseXML.xml'


select
        m.c.value('@CurrencyCode[1]', 'nvarchar(3)') as code,
        m.c.value('Isim[1]', 'nvarchar(max)') as name,
		m.c.value('Unit[1]','float') as unit,
        m.c.value('ForexBuying[1]', 'float') as unit_rate,
		m.c.value('ForexBuying[1]', 'float')/m.c.value('Unit[1]','float') as rate
    from  @_xml 
        outer apply yourXML.nodes('Tarih_Date[1]/Currency') as m(c)