<#
.NOTES
	NAME: MySQLPSLib.psm1
	AUTHOR: Tomson Philip
	DATE: 28/05/14
	KEYWORDS: Oracle, MySQL, SQL
	VERSION : 0.0.3
    LICENSE: LGPL 2.1

    This PowerShell Module attempt to provide a convenient methods for working with MySQL.
    It make use of the Oracle MySQL .Net connector version 6.8.3 available at:
    http://dev.mysql.com/downloads/connector/net/ under GPLv2 Licence
    Copyright (C) 2014  Tomson Philip

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

.SYNOPSIS
    
    VERSION 0.0.3 (12/06/14)

        All the cmdlet are still in a "raw state" this means that you still need some SQL knowledge to use these correctly.
        The ultimate goal of my Library is to provide cmdlet that doesn't require any SQL syntax knowledge.
        To achieve this I must implement a lot of checks and also friendly error messages.
        This is not the case for the moment because at first, I would like
        to bring as many functionnalities as possible before implementing parameters and parameters association validation.

        - Added 3 ENUM type to ease cmdlet parameter autocompletion
            * EnumCharacterSets (Contains the Character Sets like UTF8, CP850, etc...)
            * EnumCollationTypes (Contains the Collation types like utf8_general_ci, cp850_general_ci, etc...)
            * EnumDatatype (Contains all the datatype available in MySQL version xxxx)

        - A "Add-MySQLColumn" cmdlet has been created and commented
        - A "Add-MySQLColumnForeignKey" cmdlet has been created and commented
        - A "Add-MySQLColumnIndex" cmdlet has been created and commented
        - A "Clear-MySQLTable" cmdlet has been created and commented
        - A "Get-DataTypeCategory" cmdlet has been created and commented
        - A "Get-MySQLDeprecatedCommand" cmdlet has been created and commented
        - A "Get-MySQLTableIndex" cmdlet has been created and commented
        - A "New-MySQLDatabase" cmdlet has been created and commented
        - A "New-MySQLTable" cmdlet has been created and commented
        - A "Remove-MySQLColumn" cmdlet has been created and commented
        - A "Remove-MySQLDatabase" cmdlet has been created and commented
        - A "Remove-MySQLRow" cmdlet has been created and commented
        - A "Remove-MySQLTable" cmdlet has been created and commented
        - A "Use-MySQLDatabase" cmdlet has been created and commented

        New-MysqlUpdate has been renamed to Update-MySQLRow and an alias is available for backward compatibility via Get-MySQLDeprecatedCommand
        New-MysqlInsert has been renamed to Add-MySQLRow and an alias is available for backward compatibility via Get-MySQLDeprecatedCommand
        New-MySQLSelect has been renamed to Get-MySQLRow and an alias is available for backward compatibility via Get-MySQLDeprecatedCommand

        - Some small bugs fixes and improvements

    VERSION 0.0.2 (02/06/14)
        
        - A New-MySQLNonQuery cmdlet has been created and commented
        - Some errors in comments were corrected

    VERSION 0.0.1 (28/05/14)

        This PowerShell Module attempt to provide a convenient methods for working with MySQL.
        It make use of the Oracle MySQL .Net connector version 6.8.3

        - A "New-MySQLConnection" cmdlet has been created and commented
        - A "New-MySQLSelect" cmdlet has been created and commented
        - A "New-MySQLUpdate" cmdlet has been created and commented
        - A "New-MySQLInsert" cmdlet has been created and commented

	TODO:
        
        - Add Transaction mode support
        - Improve the "New-MysqlUpdate" cmdlet
        - Add more parameter validation

#>

<#---------------------------------------[ .NET Enum & Classes ]---------------------------------------#>

$EnumCharacterSets = @"
    public enum EnumCharacterSets
    {
        armscii8,
        ascii,
        big5,
        binary,
        cp1250,
        cp1251,
        cp1256,
        cp1257,
        cp850,
        cp852,
        cp866,
        cp932,
        dec8,
        eucjpms,
        euckr,
        gb2312,
        gbk,
        geostd8,
        greek,
        hebrew,
        hp8,
        keybcs2,
        koi8r,
        koi8u,
        latin1,
        latin2,
        latin5,
        latin7,
        macce,
        macroman,
        sjis,
        swe7,
        tis620,
        ucs2,
        ujis,
        utf16,
        utf32,
        utf8,
        utf8mb4
    }
"@

$EnumCollationTypes = @"
    public enum EnumCollationTypes
    {
        armscii8_bin,
        armscii8_general_ci,
        ascii_bin,
        ascii_general_ci,
        big5_bin,
        big5_chinese_ci,
        binary,
        cp1250_bin,
        cp1250_croatian_ci,
        cp1250_czech_cs,
        cp1250_general_ci,
        cp1250_polish_ci,
        cp1251_bin,
        cp1251_bulgarian_ci,
        cp1251_general_ci,
        cp1251_general_cs,
        cp1251_ukrainian_ci,
        cp1256_bin,
        cp1256_general_ci,
        cp1257_bin,
        cp1257_general_ci,
        cp1257_lithuanian_ci,
        cp850_bin,
        cp850_general_ci,
        cp852_bin,
        cp852_general_ci,
        cp866_bin,
        cp866_general_ci,
        cp932_bin,
        cp932_japanese_ci,
        dec8_bin,
        dec8_swedish_ci,
        eucjpms_bin,
        eucjpms_japanese_ci,
        euckr_bin,
        euckr_korean_ci,
        gb2312_bin,
        gb2312_chinese_ci,
        gbk_bin,
        gbk_chinese_ci,
        geostd8_bin,
        geostd8_general_ci,
        greek_bin,
        greek_general_ci,
        hebrew_bin,
        hebrew_general_ci,
        hp8_bin,
        hp8_english_ci,
        keybcs2_bin,
        keybcs2_general_ci,
        koi8r_bin,
        koi8r_general_ci,
        koi8u_bin,
        koi8u_general_ci,
        latin1_bin,
        latin1_danish_ci,
        latin1_general_ci,
        latin1_general_cs,
        latin1_german1_ci,
        latin1_german2_ci,
        latin1_spanish_ci,
        latin1_swedish_ci,
        latin2_bin,
        latin2_croatian_ci,
        latin2_czech_cs,
        latin2_general_ci,
        latin2_hungarian_ci,
        latin5_bin,
        latin5_turkish_ci,
        latin7_bin,
        latin7_estonian_cs,
        latin7_general_ci,
        latin7_general_cs,
        macce_bin,
        macce_general_ci,
        macroman_bin,
        macroman_general_ci,
        sjis_bin,
        sjis_japanese_ci,
        swe7_bin,
        swe7_swedish_ci,
        tis620_bin,
        tis620_thai_ci,
        ucs2_bin,
        ucs2_czech_ci,
        ucs2_danish_ci,
        ucs2_esperanto_ci,
        ucs2_estonian_ci,
        ucs2_general_ci,
        ucs2_general_mysql500_ci,
        ucs2_hungarian_ci,
        ucs2_icelandic_ci,
        ucs2_latvian_ci,
        ucs2_lithuanian_ci,
        ucs2_persian_ci,
        ucs2_polish_ci,
        ucs2_roman_ci,
        ucs2_romanian_ci,
        ucs2_sinhala_ci,
        ucs2_slovak_ci,
        ucs2_slovenian_ci,
        ucs2_spanish2_ci,
        ucs2_spanish_ci,
        ucs2_swedish_ci,
        ucs2_turkish_ci,
        ucs2_unicode_ci,
        ujis_bin,
        ujis_japanese_ci,
        utf16_bin,
        utf16_czech_ci,
        utf16_danish_ci,
        utf16_esperanto_ci,
        utf16_estonian_ci,
        utf16_general_ci,
        utf16_hungarian_ci,
        utf16_icelandic_ci,
        utf16_latvian_ci,
        utf16_lithuanian_ci,
        utf16_persian_ci,
        utf16_polish_ci,
        utf16_roman_ci,
        utf16_romanian_ci,
        utf16_sinhala_ci,
        utf16_slovak_ci,
        utf16_slovenian_ci,
        utf16_spanish2_ci,
        utf16_spanish_ci,
        utf16_swedish_ci,
        utf16_turkish_ci,
        utf16_unicode_ci,
        utf32_bin,
        utf32_czech_ci,
        utf32_danish_ci,
        utf32_esperanto_ci,
        utf32_estonian_ci,
        utf32_general_ci,
        utf32_hungarian_ci,
        utf32_icelandic_ci,
        utf32_latvian_ci,
        utf32_lithuanian_ci,
        utf32_persian_ci,
        utf32_polish_ci,
        utf32_roman_ci,
        utf32_romanian_ci,
        utf32_sinhala_ci,
        utf32_slovak_ci,
        utf32_slovenian_ci,
        utf32_spanish2_ci,
        utf32_spanish_ci,
        utf32_swedish_ci,
        utf32_turkish_ci,
        utf32_unicode_ci,
        utf8_bin,
        utf8_czech_ci,
        utf8_danish_ci,
        utf8_esperanto_ci,
        utf8_estonian_ci,
        utf8_general_ci,
        utf8_general_mysql500_ci,
        utf8_hungarian_ci,
        utf8_icelandic_ci,
        utf8_latvian_ci,
        utf8_lithuanian_ci,
        utf8_persian_ci,
        utf8_polish_ci,
        utf8_roman_ci,
        utf8_romanian_ci,
        utf8_sinhala_ci,
        utf8_slovak_ci,
        utf8_slovenian_ci,
        utf8_spanish2_ci,
        utf8_spanish_ci,
        utf8_swedish_ci,
        utf8_turkish_ci,
        utf8_unicode_ci,
        utf8mb4_bin,
        utf8mb4_czech_ci,
        utf8mb4_danish_ci,
        utf8mb4_esperanto_ci,
        utf8mb4_estonian_ci,
        utf8mb4_general_ci,
        utf8mb4_hungarian_ci,
        utf8mb4_icelandic_ci,
        utf8mb4_latvian_ci,
        utf8mb4_lithuanian_ci,
        utf8mb4_persian_ci,
        utf8mb4_polish_ci,
        utf8mb4_roman_ci,
        utf8mb4_romanian_ci,
        utf8mb4_sinhala_ci,
        utf8mb4_slovak_ci,
        utf8mb4_slovenian_ci,
        utf8mb4_spanish2_ci,
        utf8mb4_spanish_ci,
        utf8mb4_swedish_ci,
        utf8mb4_turkish_ci,
        utf8mb4_unicode_ci
    }
"@

$EnumDataType = @"
    public enum EnumDatatype
    {
        @TINYINT,
        @SMALLINT,
        @MEDIUMINT,
        @INT,
        @BIGINT,
        @DECIMAL,
        @FLOAT,
        @DOUBLE,
        @REAL,
        @BIT,
        @BOOLEAN,
        @SERIAL,
        @DATE,
        @DATETIME,
        @TIMESTAMP,
        @TIME,
        @YEAR,
        @CHAR,
        @VARCHAR,
        @TINYTEXT,
        @TEXT,
        @MEDIUMTEXT,
        @LONGTEXT,
        @BINARY,
        @VARBINARY,
        @TINYBLOB,
        @MEDIUMBLOB,
        @BLOB,
        @LONGBLOB,
        @ENUM,
        @SET,
        @GEOMETRY,
        @POINT,
        @LINESTRING,
        @POLYGON,
        @MULTIPOINT,
        @MULTILINESTRING,
        @MULTIPOLYGON,
        @GEOMETRYCOLLECTION
    }
"@

Add-Type -TypeDefinition $EnumCollationTypes
Add-Type -TypeDefinition $EnumCharacterSets
Add-Type -TypeDefinition $EnumDataType

$Numeric = @(
    "SMALLINT",
    "MEDIUMINT",
    "INT",
    "BIGINT",
    "DECIMAL",
    "FLOAT",
    "DOUBLE",
    "REAL",
    "BIT",
    "BOOLEAN",
    "SERIAL"
)

$Text = @(
    "VARCHAR",
    "TINYTEXT",
    "TEXT",
    "MEDIUMTEXT",
    "LONGTEXT",
    "BINARY",
    "VARBINARY",
    "TINYBLOB",
    "MEDIUMBLOB",
    "BLOB",
    "LONGBLOB",
    "ENUM",
    "SET"
)

$Date = @(
    "DATETIME",
    "TIMESTAMP",
    "TIME",
    "YEAR"
)

$Geometry = @(
    "POINT",
    "LINESTRING",
    "POLYGON",
    "MULTIPOINT",
    "MULTILINESTRING",
    "MULTIPOLYGON",
    "GEOMETRYCOLLECTION"
)

<#---------------------------------------[ Functions ]---------------------------------------#>
Function Get-MySQLDeprecatedCommand {
    <#
    .SYNOPSIS
    Generate aliases for backward compatibility
    
    .DESCRIPTION
    Generate aliases for backward compatibility

    .EXAMPLE
    Get-MySQLDeprecatedCommand

    Description
    -----------
    Calls a function that will generate aliases for backward compatibility
    
    .NOTES
    
    .LINK 
    
    #>
	Set-Alias New-MySQLUpdate Update-MySQLRow -Scope "Global"
    Set-Alias New-MySQLInsert Add-MySQLRow -Scope "Global"
    Set-Alias New-MySQLSelect Get-MySQLRow -Scope "Global"
}

Function New-MySQLConnection{
    <#
    .SYNOPSIS
    Create a MySQL Connection 
    
    .DESCRIPTION
    Create a MySQL Connection
    
    .PARAMETER Server
    The targeted MySQL server you want to connect to

    .PARAMETER Database
    The initial database you want to work with
    
    .PARAMETER Port
    The TCP port used for the connection (it is "3306" by default)

    .PARAMETER Username
    The username required for the connection

    .PARAMETER Password
    The password required for the connection

    .EXAMPLE
    [MySql.Data.MySqlClient.MySqlConnection]$MysqlConnection = New-MysqlConnection -Server "127.0.0.1" -Database "Powershell" -Username "root" -Password "password"

    Description
    -----------
    Calls a function which create and returns an "MySql.Data.MySqlClient.MySqlConnection" object
    
    .NOTES
    
    .LINK 
    
    #> 
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$Server,
        #[parameter(Mandatory=$true)]
        [string]$Database,
        [string]$Port="3306",
        [parameter(Mandatory=$true)]
        [string]$Username,
        [parameter(Mandatory=$true)]
        [string]$Password
    )
    process{
        $ConnectionString = "server=" + $Server + ";port=" + $Port + ";uid=" + $Username + ";pwd=" + $Password
        if($Database){
            $ConnectionString += ";database=" + $Database
        }
        [MySql.Data.MySqlClient.MySqlConnection]$Connection = New-Object MySql.Data.MySqlClient.MySqlConnection($ConnectionString)
        $Connection.Open()
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $Database",$Connection)
        return $Connection
    }
}

Function Get-MySQLRow{
    <#
    .SYNOPSIS
    Make a MySQL select query
    
    .DESCRIPTION
    Make a MySQL select query
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Query
    The query you want to run

    .EXAMPLE
    Get-MySQLRow -Connection $MysqlConnection -Query "SELECT FIELD_1,FIELD_2 FROM TABLE_1 WHERE FIELD_1 = 'VALUE_1'"

    Description
    -----------
    Calls a function which perform a MySQL SELECT and returns a System.Array containing System.Data.DataRow object(s)
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Query
    )
    process{
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query,$Connection)
        $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
        $DataSet = New-Object System.Data.DataSet
        $RecordCount = $dataAdapter.Fill($dataSet,"Result")
        return $DataSet.Tables[0]
    }
}

Function Update-MySQLRow{
    <#
    .SYNOPSIS
    Make a MySQL update query
    
    .DESCRIPTION
    Make a MySQL update query
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Table
    The table name you want to work with

    .PARAMETER Datas
    System.Collections.Hashtable containing the field name as key and their associated value as value

    .PARAMETER Where
    The MySQL WHERE Conditions as a string

    .EXAMPLE
    Update-MySQLRow -Connection $MysqlConnection -Table "TABLE_1" -Datas @{
        FIELD_1 = "VALUE_1"
        FIELD_2 = "VALUE_2"
    } -Where "FIELD_3 < VALUE_3"

    Description
    -----------
    Calls a function which perform a MySQL UPDATE and return the number of affected object(s)
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table,
        [System.Collections.Hashtable]$Datas,
        [String]$Where
    )
    process{
        $Separator, $ValuesString = ""

        foreach($key in $Datas.Keys){
            $ValuesString += $Separator + $key + "=@" + $key
            $Separator = ","
        }

        $Query = "UPDATE $Table SET $ValuesString WHERE $Where;"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query

        foreach($key in $Datas.Keys){
            $Name = "@" + $key
            $Command.Parameters.AddWithValue("$Name",$Datas[$key])
        }
        $Command.Prepare()

        $RowsUpdated = $Command.ExecuteNonQuery()

        if ($RowsUpdated) {
            return $RowsUpdated
        }else{
            return $false
        }
    }
}

Function Add-MySQLRow{
    <#
    .SYNOPSIS
    Make a MySQL insert query
    
    .DESCRIPTION
    Make a MySQL insert query
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Table
    The table name you want to work with

    .PARAMETER Datas
    System.Collections.Hashtable containing the field name as key and their associated value as value

    .EXAMPLE
    Add-MySQLRow -Connection $MysqlConnection -Table "TABLE_1" -Datas @{
        FIELD_1 = VALUE_1
        FIELD_2 = VALUE_2
        FIELD_3 = VALUE_3
        FIELD_4 = VALUE_4
    }

    Description
    -----------
    Calls a function which perform a MySQL INSERT and return the number of inserted rows
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table,
        [System.Collections.Hashtable]$Datas
    )
    process{

        $NamesString, $Separator, $ValuesString = ""

        foreach($key in $Datas.Keys){
            $NamesString += $Separator + $key
            $ValuesString += $Separator + "@" + $key
            $Separator = ","
        }

        $Query = "INSERT INTO $Table ($NamesString) VALUES ($ValuesString);"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query

        foreach($key in $Datas.Keys){
            $Name = "@" + $key
            $Command.Parameters.AddWithValue("$Name",$Datas[$key])
        }

        $Command.Prepare()
        $RowsInserted = $Command.ExecuteNonQuery() | Out-Null

        if ($RowsInserted) {
            return $RowInserted
        }else{
            return $false
        }
    }
}

Function New-MySQLNonQuery {
    <#
    .SYNOPSIS
    Make a MySQL  non-query
    
    .DESCRIPTION
    Make a MySQL non-query
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Query
    The query you want to run

    .EXAMPLE
    New-MysqlSelect -Connection $MysqlConnection -Query "INSERT INTO TABLE_1 (FIELD_1,FIELD_2) VALUES ('VALUE_1','VALUE_2');"

    Description
    -----------
    Calls a function which perform a MySQL INSERt/UPDATE/DELETE query and return the number of affected elements
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Query
    )
    process{
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query,$Connection)
        $RowsChanged = $Command.ExecuteNonQuery()
        if ($RowsChanged) {
            return $RowChanged
        }else{
            return $false
        }
    }
}

Function Get-DataTypeCategory{
    param(
        [string]$Datatype
    )
    process{
        if($Numeric -contains $Datatype.ToUpper()){
            return 0
        }
        if($Text -contains $Datatype.ToUpper()){
            return 1
        }
        if($Date -contains $Datatype.ToUpper()){
            return 2
        }
        if($Geometry -contains $Datatype.ToUpper()){
            return 3
        }
    }
}

Function Add-MySQLColumn {
    <#
    .SYNOPSIS
    Create a new Column in a given MySQL Table
    
    .DESCRIPTION
    Create a new Column in a given MySQL Table
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Table
    The table you want to alter

    .PARAMETER Name
    The name you want to assign to the new column

    .PARAMETER DataType
    The data type of the new column

    .PARAMETER NotNull
    Set if the value can be null or not

    .PARAMETER Size
    The size of the data

    .PARAMETER Default
    Set the default value for the data

    .PARAMETER CollationType
    The collation type you want to use for the data

    .PARAMETER Comment
    A simple comment you want to add to the column

    .PARAMETER Index
    Set this column as an index

    .EXAMPLE
    Add-MySQLColumn -Connection $MysqlConnection -Table "TABLE_1" -Name "COLUMN_2" -DataType "VarChar" -Size 10 -CollationType "utf8_general_ci" -Comment "Nice Column" -NotNull -Default "EMPTY"

    Description
    -----------
    Calls a function which Create a new Column on a given MySQL Table
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table,
        [parameter(Mandatory=$true)]
        [String]$Name,
        [parameter(Mandatory=$true)]
        [EnumDatatype]$DataType,
        [switch]$NotNull,
        [parameter(Mandatory=$true)]
        [int]$Size,
        [String]$Default,
        #[switch]$Unique,
        #[switch]$AutoIncrement,
        [EnumCollationTypes]$CollationType,
        [String]$Comment,
        [Switch]$Index
    )
    process{

        $DataType = [System.Enum]::GetName($([EnumDatatype]),$DataType)

        $Query = "ALTER TABLE $Table ADD COLUMN $Name $DataType($Size)"
        
        switch($(Get-DataTypeCategory -Datatype $DataType)){
            0 {
                
            }
            1 {
                if($CollationType){
                    $Collation = [System.Enum]::GetName($([EnumCollationTypes]),$CollationType)
                    $Query += " CHARACTER SET $($Collation.Split("_")[0]) COLLATE $Collation"
                }
            }
            2 {
            
            }
            3 {
            
            }
        }

        if($NotNull){
            $Query += " NOT NULL"
        }else{
            $Query += " NULL"
        }

        if($Default){
            if($Default.ToUpper() -ne "NULL" ){
                $Query += " DEFAULT '$Default'"
            }else{
                $Query += " DEFAULT NULL"
            }
        }

        if($Comment){
            $Query += " COMMENT '$Comment'"
        }

        if($Index){
            #Add-MySQLColumnIndex -Connection $Connection -Table $Table -Name $Name
        }

        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        if($Index){
            Add-MySQLColumnIndex -Connection $Connection -Table $Table -Name $Name
        }

        return $Query
    }
}

Function New-MySQLTable {
    <#
    .SYNOPSIS
    Create a MySQL table
    
    .DESCRIPTION
    Create a MySQL table
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Name
    The name of the table you want to create

    .PARAMETER CharSet
    The default character set for the table

    .PARAMETER KeyName
    The column that will contains the primary key of the table

    .PARAMETER DataType
    The datatype of the primary key

    .PARAMETER AutoIncrement
    Tels if the index will autoincrement itself (Datatype must be a number for this to work)

    .PARAMETER Size
    The maximum size of the primary key

    .PARAMETER IfNotExists
    Check if the table already exists before creating it

    .PARAMETER Comment
    Some words describing your table

    .EXAMPLE

    New-MySQLTable -Connection $MysqlConnection -Name "TABLE_1" -CharSet utf8 -KeyName "ID" -DataType INT -Size 10 -IfNotExists -Comment "Interresting Comment"
    

    Description
    -----------
    Calls a function which create a MySQL table
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Name,
        [EnumCharacterSets]$CharSet,
        [parameter(Mandatory=$true)]
        [String]$KeyName,
        [parameter(Mandatory=$true)]
        [EnumDatatype]$DataType,
        [switch]$AutoIncrement,
        [int]$Size,
        [switch]$IfNotExists,
        [string]$Comment

    )
    process{
        
        $DataType = [System.Enum]::GetName($([EnumDatatype]),$DataType)

        $Query = "CREATE TABLE"

        if($IfNotExists){
            $Query += " IF NOT EXISTS"
        }

        $Query += " $Name (``$KeyName`` $DataType($Size) NOT NULL"
        
        if($AutoIncrement){
            $Query += " AUTO_INCREMENT"
        }

        $Query += ", PRIMARY KEY (``$KeyName``)) ENGINE=InnoDB"
        
        if($CharSet){
            $Chars = [System.Enum]::GetName($([EnumCharacterSets]),$CharSet)
            $Query += " CHARSET=$Chars"
        }

        if($Comment){
            $Query += " COMMENT='$Comment'"
        }

        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        return $Query
    }
}

Function New-MySQLDatabase {
    <#
    .SYNOPSIS
    Create a new MySQL database
    
    .DESCRIPTION
    Create a new MySQL database
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Name
    The name of the database that must be created

    .PARAMETER CollationType
    The collation type you want to use for the data

    .EXAMPLE
    New-MySQLDatabase -Connection $MysqlConnection -Name "DATABASE_1" -CollationType "utf8_general_ci"

    Description
    -----------
    Calls a function which create a new MySQL database
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Name,
        [EnumCollationTypes]$CollationType
    )
    process{
        $Collation = [System.Enum]::GetName($([EnumCollationTypes]),$CollationType)
        $Query = "CREATE DATABASE ``$Name`` DEFAULT CHARACTER SET $($Collation.Split("_")[0]) COLLATE $Collation;"

        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        return $Name
    }
}

Function Remove-MySQLRow{
    <#
    .SYNOPSIS
    Make a MySQL delete query
    
    .DESCRIPTION
    Make a MySQL delete query
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Table
    The table name you want to work with

    .PARAMETER Where
    The MySQL WHERE Conditions as a string

    .EXAMPLE
    Remove-MySQLRow -Connection $MysqlConnection -Table "TABLE_1" -Where "FIELD_3 = VALUE_3"

    Description
    -----------
    Calls a function which perform a MySQL DELETE and return the number of affected object(s)
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table,
        [parameter(Mandatory=$true)]
        [String]$Where
    )
    process{

        $Query = "DELETE FROM $Table WHERE $Where;"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.Prepare()

        $RowsDeleted = $Command.ExecuteNonQuery()

        if ($RowsDeleted) {
            return $RowsDeleted
        }else{
            return $false
        }
    }
}

Function Remove-MySQLColumn {
    <#
    .SYNOPSIS
    Delete a column in a given MySQL Table
    
    .DESCRIPTION
    Delete a column in a given MySQL Table
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Table
    The table you want to alter

    .PARAMETER Name
    The name of the column you want to delete

    .EXAMPLE
    Remove-MySQLColumn -Connection $MysqlConnection -Table "TABLE_1" -Name "COLUMN_2"

    Description
    -----------
    Calls a function which delete a column on a given MySQL Table
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table,
        [parameter(Mandatory=$true)]
        [String]$Name
    )
    process{
        $Query = "ALTER TABLE ``$Table`` DROP ``$Name``"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        return $Query
    }
}

Function Clear-MySQLTable {
    <#
    .SYNOPSIS
    Clear all the data in a given MySQL Table
    
    .DESCRIPTION
    Clear all the data in a given MySQL Table
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Table
    The table you want to clear

    .EXAMPLE
    Clear-MySQLTable -Connection $MysqlConnection -Table "TABLE_1"

    Description
    -----------
    Calls a function which clear the data of a given MySQL Table
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table
    )
    process{
        $Query = "TRUNCATE TABLE ``$Table``"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        return $Query
    }
}

Function Remove-MySQLTable {
    <#
    .SYNOPSIS
    Delete a given MySQL Table
    
    .DESCRIPTION
    Delete a given MySQL Table
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Table
    The table you want to delete

    .EXAMPLE
    Remove-MySQLTable -Connection $MysqlConnection -Table "TABLE_1"

    Description
    -----------
    Calls a function which delete a given MySQL Table
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table
    )
    process{
        $Query = "DROP TABLE ``$Table``"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        return $Query
    }
}

Function Remove-MySQLDatabase {
    <#
    .SYNOPSIS
    Delete a given MySQL Database
    
    .DESCRIPTION
    Delete a given MySQL Database
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Database
    The Database you want to delete

    .EXAMPLE
    Remove-MySQLDatabase -Connection $MysqlConnection -Database "DATABASE_1"

    Description
    -----------
    Calls a function which delete a given MySQL Database
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Database
    )
    process{
        $Query = "DROP DATABASE ``$Database``"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        return $Query
    }
}

Function Add-MySQLColumnForeignKey {
    <#
    .SYNOPSIS
    Create a foreign key constraint on a given MySQL Table
    
    .DESCRIPTION
    Create a foreign key constraint on a given MySQL Table
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Name
    The table you want to delete

    .PARAMETER ParentTable
    The table you want to delete

    .PARAMETER ChildTable
    The table you want to delete

    .PARAMETER ParentKey
    The table you want to delete

    .PARAMETER ChildKey
    The table you want to delete

    .EXAMPLE
    Add-MySQLColumnForeignKey -Connection $MysqlConnection -Name "FK_NAME_1" -ParentTable "TABLE_1" -ChildTable "TABLE_2" -ParentKey "ID_1" -ChildKey "ID_2"

    Description
    -----------
    Calls a function which create a foreign key constraint on a given MySQL Table
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Name,
        [parameter(Mandatory=$true)]
        [String]$ParentTable,
        [parameter(Mandatory=$true)]
        [String]$ChildTable,
        [parameter(Mandatory=$true)]
        [String]$ParentKey,
        [parameter(Mandatory=$true)]
        [string]$ChildKey
    )
    process{
        if ($(Get-MySQLTableIndex -Connection $Connection -Table $ParentTable).Column_name -contains $ParentKey){
            $Query = "ALTER TABLE $ChildTable ADD CONSTRAINT $Name FOREIGN KEY (``$ChildKey``) REFERENCES $ParentTable(``$ParentKey``)"
            [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
            $Command.Connection = $Connection
            $Command.CommandText = $Query
            $Command.ExecuteNonQuery() | Out-Null
            return $Query
        }else{
            return "$ParentKey in $ParentTable not found !!!"
        }
    }
}

Function Get-MySQLTableIndex{
    <#
    .SYNOPSIS
    Retrieve all the indexes for a given MySQL table
    
    .DESCRIPTION
    Retrieve all the indexes for a given MySQL table
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Query
    The table from which you want to get the indexes

    .EXAMPLE
    Get-MySQLTableIndex -Connection $MysqlConnection -Table "TABLE_1"

    Description
    -----------
    Calls a function which retrieve all the indexes for a given MySQL table
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table
    )
    process{
        $Query = "SHOW INDEX FROM $Table"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query,$Connection)
        $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
        $DataSet = New-Object System.Data.DataSet
        $RecordCount = $dataAdapter.Fill($dataSet,"Result")
        return $DataSet.Tables[0]
    }
}

Function Use-MySQLDatabase {
    <#
    .SYNOPSIS
    Use a MySQL Database
    
    .DESCRIPTION
    Use a MySQL Database
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Database
    The table you want to delete

    .EXAMPLE
    Use-MySQLDatabase -Connection $MysqlConnection -Database "Database_1"

    Description
    -----------
    Calls a function which use a specified MySQL database
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Database
    )
    process{
        $Query = "USE ``$Database``"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        return $Query
    }
}

Function Add-MySQLColumnIndex {
    <#
    .SYNOPSIS
    Create an index on a given column
    
    .DESCRIPTION
    Create an index on a given column
    
    .PARAMETER Connection
    The targeted MySQL server you want to connect to

    .PARAMETER Table
    The table you want add the index to

    .PARAMETER Name
    The name of the index you want to add

    .EXAMPLE
    Add-MySQLColumnIndex -Connection $MysqlConnection -Table "TABLE_1" -Name "COLUMN_NAME"

    Description
    -----------
    Calls a function which create an index on a given column
    
    .NOTES
    
    .LINK 
    
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [parameter(Mandatory=$true)]
        [String]$Table,
        [parameter(Mandatory=$true)]
        [String]$Name
    )
    process{
        $Query = "ALTER TABLE $Table ADD INDEX $Name ($Name)"
        [MySql.Data.MySqlClient.MySqlCommand]$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
        $Command.Connection = $Connection
        $Command.CommandText = $Query
        $Command.ExecuteNonQuery()

        return $Query
    }
}