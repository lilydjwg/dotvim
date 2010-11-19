let g:xmldata_stl_sql= {
\ 'transaction': [ 
\ [],
\ { 'dataSource' : [],'isolation' : []}
\  ],
\ 'query': [ 
\ [],
\ { 'var' : [],'scope' : [],'sql' : [],'dataSource' : [],'startRow' : [],'maxRows' : []}
\  ],
\ 'update': [ 
\ [],
\ { 'var' : [],'scope' : [],'sql' : [],'dataSource' : []}
\  ],
\ 'param': [ 
\ [],
\ { 'value' : []}
\  ],
\ 'dateParam': [ 
\ [],
\ { 'value' : [],'type' : []}
\  ],
\ 'setDataSource': [ 
\ [],
\ { 'var' : [],'scope' : [],'dataSource' : [],'driver' : [],'url' : [],'user' : [],'password' : []}
\ ],
\ 'vimxmltaginfo': { 
\ 'transaction' : [ ' ', '         Provides nested database action elements with a shared Connection,         set up to execute all statements as one transaction.     '],
\ 'query' : [ ' ', '         Executes the SQL query defined in its body or through the         sql attribute.     '],
\ 'update' : [ ' ', '         Executes the SQL update defined in its body or through the         sql attribute.     '],
\ 'param' : [ ' ', '         Sets a parameter in an SQL statement to the specified value.     '],
\ 'dateParam' : [ ' ', '         Sets a parameter in an SQL statement to the specified java.util.Date value.     '],
\ 'setDataSource' : [ ' ', '         Creates a simple DataSource suitable only for prototyping.     ']
\ },
\ 'vimxmlattrinfo': { 
\ 'dataSource' : [ ' ', ' DataSource associated with the database to access. A String value represents a relative path to a JNDI resource or the parameters for the JDBC DriverManager facility.         '],
\ 'isolation' : [ ' ', ' Transaction isolation level. If not specified, it is the isolation level the DataSource has been configured with.         '],
\ 'var' : [ ' ', ' Name of the exported scoped variable for the query result. The type of the scoped variable is javax.servlet.jsp.jstl.sql. Result (see Chapter 16 "Java APIs").         '],
\ 'scope' : [ ' ', ' Scope of var.         '],
\ 'sql' : [ ' ', ' SQL query statement.         '],
\ 'startRow' : [ ' ', ' The returned Result object includes the rows starting at the specified index. The first row of the original query result set is at index 0. If not specified, rows are included starting from the first row at index 0.         '],
\ 'maxRows' : [ ' ', ' The maximum number of rows to be included in the query result. If not specified, or set to -1, no limit on the maximum number of rows is enforced.         '],
\ 'value' : [ ' ', ' Parameter value.         '],
\ 'type' : [ ' ', ' One of "date", "time" or "timestamp".         '],
\ 'driver' : [ ' ', ' JDBC parameter: driver class name.         '],
\ 'url' : [ ' ', ' JDBC parameter: URL associated with the database.         '],
\ 'user' : [ ' ', ' JDBC parameter: database user on whose behalf the connection to the database is being made.         '],
\ 'password' : [ ' ', ' JDBC parameter: user password         ']
\ },
\}
