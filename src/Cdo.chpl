/*
 * Copyright (C) 2017 Marcos Cleison Silva Santana
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
Cdo - Chapel Data Object is a library that helps to access RDBMS databases like Postgres, Mysql or Sqlite.

One of the objectives of this library is to provide to Chapel developers a common API to access relational databases. 

Some features found in this library is inspired by PHP PDO, Python DB API and Go SQL API.

This module is focused on providing interfaces, base classes, and helpers that allows hiding complexity of different database connection libraries. 

 -  Database Connection Class
    + :chpl:class `Conection`
    + :chpl:class `ConectionBase`
 -  Database Cursor Class
    + :chpl:class `Cursor`
    + :chpl:class `CursorBase`
 -  Data Row Class
    + :chpl:class `Row`
-  Data ColumnInfo Class
    + :chpl:class `ColumnInfo`

*/

module Cdo{

use Reflection;



pragma "no doc"
class Model{
    var _table:string;
    var _primary_key="id";
    var dbCon:Connection;
    proc Model(dbCon:Connection){
    
    }
}



pragma "no doc"
enum CdoType{
    DATE,
    TIME,
    TIMESTAMP,
    TIMESTAMP_FROM_TICKS,
    TIME_FROM_TICKS,
    DATE_FROM_TICKS,
    BINARY,
    STRING, 
    NUMBER, 
    DATETIME, 
    ROWID 
}

/*
The  `Row` class stores information from result set send by the database server.


*/
class Row{
    pragma "no doc"
    var rowColDomain:domain(string);
    pragma "no doc"
    var data:[rowColDomain]string;
    pragma "no doc"
    var num:int(32);
/*
`addData` adds in an associative array the column and its correspondent data.
        :arg colname: `string` name of the column.
        :type colname: `string`

        :arg datum: `string` data returned.
        :type datum: `string`
       
*/

    proc addData(colname:string, datum:string){
        this.data[colname] = datum;
    }
/*
    `get` gets the data from column name.
        :arg colname: `string` name of the column.
        :type colname: `string`

     :return: data value of the column `colname`.
     :rtype: `string`
       
*/
    
    proc get(colname:string):string{
        if(this.rowColDomain.member(colname)){
            return this.data[colname];
        }else{
            return "";
        }
    }
/*
    `this[colname]` gets the data from column name.
        :arg colname: `string` name of the column.
        :type colname: `string`

     :return: data value of the column `colname`.
     :rtype: `string`
       
*/


    proc this(colname:string):string{
        return this.get(colname);
    }
/*
    `this[colnum]` gets the data from column number.
        :arg colnum: `int` number of the column.
        :type colnum: `int`

     :return: data value of the column `colnum`.
     :rtype: `string`
       
*/

    proc this(colnum:int):string{
        var i = 1;
        for idx in this.rowColDomain{
            if(i == colnum){
                return this.data[idx];
            }
            i+=1;
        }
        return "";
    }
    /*pragma "no doc"
    proc writeThis(f){
        try{
            for col in this.rowColDomain{
                f.write(col,"=",this.data[col]," ");
            }
            f.writeln(" ");

        }catch{
            writeln("Cannot Write Row");//todo: improves messages with log
        }
    }
*/

}

/*
The `ColumnInfo` class holds infomration about returned columns.
*/
class ColumnInfo{
    pragma "no doc"
    var coltype:string;
    pragma "no doc"
    var colnum:int(32);
    pragma "no doc"
    var name:string;
}
/*
The `ConnectionBase` class is provides an interface-like for the database Driver developers for Cto  
All database drivers/connectors need to inherit this class and override non-helper methods.
*/
class ConnectionBase{

/*
    The method `cursor` creates a cursor to query and retrieve results from database. 
    
    :return: result cursor .
    :rtype: `Cursor`
*/

    proc cursor():Cursor{

        return nil;
    }
pragma "no doc"
    proc getNativeConection():opaque{

        //todo:
        return nil;

    }

pragma "no doc"

proc Begin(){

}

pragma "no doc"
    proc commit(){

    }
    pragma "no doc"
    proc rollback(){

    }
    pragma "no doc"
    proc close(){

    }

    proc setAutocommit(commit:bool){

    }


    pragma "no doc"
    proc helloWorld(){
        writeln("Hello from ConnectionBase");
    }

    proc table(table:string):QueryBuilder{
        return nil;
    } 

    



}
/*
The `CursorBase` is the interface-like base class that treats queries and returned result from database. 
All database driver cursors should implement its methods inheriting from this class 
*/
class CursorBase{
pragma "no doc"
    var colDomain:domain(int(32));
pragma "no doc"    
    var columns:[colDomain]ColumnInfo;
/*
`__addColumn` is a helper method that adds column infomrations to column result list.
        :arg colnum: `int` number of the column.
        :type colnum: `int`
        
        :arg colname: `string` name of the column.
        :type colname: `string`

        :arg coltype: `string` type of the column.
        :type coltype: `string`

   

*/
    proc __addColumn(colnum:int(32),colname:string,coltype:string=""){
        this.columns[colnum] = new ColumnInfo(name=colname,colnum=colnum,coltype=coltype);  
    }
/*
`__removeColumns` is a helper method that clears column infomation list.
*/
    proc __removeColumns(){

        //if(this.columns[colnum]!=nil){
            for colnum in this.colDomain{
                this.colDomain -= colnum;
            }
            
        //}

    }
pragma "no doc"
    proc getColumnInfo(colnum:int(32)):ColumnInfo{
        return this.columns[colnum];
    }

    proc hasColumn(name:string):bool{
        for col in this.columns{
            if(name == col.name){
                return true;
            }
        }
        return false;
    }

pragma "no doc"
    proc printColumns(){
        for col in this.columns{
            writeln(col,"\t");
        }
        writeln("\n++++++++++++++++++++++++++++++++++++++++++++");
    }
/*
    `rowcount` gets the number of rows in result set.
     :return: Number of rows in the result set.
     :rtype: `int(32)`
*/
    proc rowcount():int(32){
        return 0;
    }
/*
*/
pragma "no doc"
    proc callproc(){

    }
/*
    `close` frees the result result set resources.
     :return: Number of rows in the result set.
     :rtype: `int(32)`
*/   
    proc close(){

    }
    /*
    `execute` executes SQL commands.

    :arg query: `string` SQL command.
    :type query: `string`

    :arg params: `tuple` tuple of parameters.
    :type params: `tuple`

*/  
    proc execute(query:string, params){

    }
/*
    `execute` executes SQL commands.

    :arg query: `string` SQL command.
    :type query: `string`
*/
   proc execute(query:string){
       
   }

/*
    `query` sends SQL queries.

    :arg query: `string` SQL command.
    :type query: `string`

*/ 
   proc query(query:string){
      
   }

   /*
    `query` sends SQL queries.

    :arg query: `string` SQL command.
    :type query: `string`
    :arg params: `tuple` tuple of parameters.
    :type params: `tuple`

    */ 

   proc query(query:string,params){

      
   }

   pragma "no doc"
   proc dump(){

   }
   

 pragma "no doc"
    proc executemany(str:string, pr){
      //writeln(pr[1][1]);
    }

   /*
    `fetchone` gets one row from result set.

    
    :return: Row data.
    :rtype: `Row`
    */ 

    proc fetchone():Row{
        return nil;
    }

    proc fetchAsRecord(ref el:?eltType):eltType{
        //var el2: eltType = new eltType;
        var row:Row = this.fetchone();

        if(row==nil){
            return nil;
        }
        for param i in 1..numFields(eltType) {
            var fname = getFieldName(eltType,i);
            if(hasColumn(fname)){
             var s=row[fname];
              getFieldRef(el, i)=s;// =  row[fname];
            }
        }

        return el;
    }

    pragma "no doc"
    
    proc __objToArray(ref el:?eltType){

        var cols_dim:domain(string);
        var cols:[cols_dim]string;

        for param i in 1..numFields(eltType) {
            var fname = getFieldName(eltType,i);
            var value = getFieldRef(el, i);// =  row[fname];
            cols[fname:string] = value:string;
        }

        return cols;
    }
    /*
    `insertRecord` inserts data from (object) record/class  fields into database  table.
        :arg table: `string` name of the datbase table.
        :type el: `?eltType` Object containing the data in class/record fields. 
        :return: Insert sql generted to do the insert operation.
        :rtype: `string`
    */
    proc insertRecord(table:string, ref el:?eltType):string{
        
        return "";
    }


/*
    `insert` inserts associative array into database  table.
        :arg table: `string` name of the database table.
        :type data: `[?D]string` Associative array with columns name as index. 
        :return: Insert sql generted to do the insert operation.
        :rtype: `string`
    */
    proc insert(table:string, data:[?D]string):string{
        return "";
    }

   /*
    `fetchmany` iterates on `count` rows.

    :arg count: `int` Number of rows that wants to interate on.
    :type count: `int`
    
    :return: Row data.
    :rtype: `Row`
    */ 

    iter fetchmany(count:int=0):Row{
        
    }
    /*
    `fetchall` iterates on all rows.
    
    :return: Row data.
    :rtype: `Row`
    */ 

    iter fetchall():Row{
       
    }
    /*
    `this[idx]` accesses the idx-th row.
    :return: Row data.
    :rtype: `Row`
    */
    proc this(idx:int):Row{
        
    }

    /*
    `these` iterates on all rows.
    
    :return: Row data.
    :rtype: `Row`
    */ 
    iter these()ref:Row{

    }

    /*
    `next` increses the cursor position.
    
    :return: Row data.
    :rtype: `Row`
    */
    proc next(){
        
    }
    pragma "no doc"
    proc messages(){

    }

}

type whereType = 4*string;

class StatementData{
    var op:string;
    var data_dim:domain(1);
    var data:[data_dim]string;

    var where_data_dim:domain(1);
    var where_data:[where_data_dim]whereType;

    proc StatementData(op, data){
        this.op = op;
        this.data.push_back(data);
    }

    proc StatementData(op:string, data:whereType){
        this.where_data.push_back(data);
        this.op=op;
    }
    
    proc this(i:int):string{
        try{
            if(this.op=="where"){
                return this.where_data[i];
            }else{
                return this.data[i];
            }
        }catch{
            writeln("Error Statement Data");
        }
    }

    iter these()ref:string{
        try{
            if(this.op=="where"){
                for obj in this.where_data{
                    yield obj;
                }
            }else{
                for obj in this.data{
                    yield obj;
                }
            }
        }catch{
            writeln("Error Statement Data");
        }
    }

    proc append(data:string){
        this.data.push_back(data);
    }
    proc append(data:[?D]string){
        this.data.push_back(data);
    }
    proc append(data:whereType){
        this.where_data.push_back(data);
    }

    proc setData(data){
        this.data=data;
    }
    proc getData(){
        return this.data;
    }
    proc getWhereData(){
        return this.where_data;
    }
    
    proc writeThis(f){
        try{
            if(this.op=="where"){
                for c in this.where_data{
                    f.writeln("Op:",this.op," *data=",c);
                }
            }else{
                for c in this.data{
                    f.writeln("Op:",this.op," data=",c);
                }
            }
        }catch{
            writeln("Error on write");
        }
    }
}

class StatementCompiler{
    var _statements_dim:domain(string);
    var _statements:[_statements_dim]StatementData;

    proc init(stmt:[?D]StatementData){
       this._statements = stmt;
       this._statements_dim = D;
    }

    proc has(opname:string):bool{
        return this._statements_dim.member(opname);
    }

    proc get(opname):StatementData{
        return this._statements[opname];
    }
}



class QueryBuilderBase{

    var _where_cond_dim:domain(1);
    var _where_cond:[_where_cond_dim]whereType;

    var _column_names_dom: domain(1);
    var _column_names: [_column_names_dom]string;

    var table:string = "";
    var con:Connection;

    var _optype_dim:domain(1);
    var _optype:[_optype_dim]string;

    var _statements_dim:domain(string);
    var _statements:[_statements_dim]StatementData;

    var sql="";


    proc QueryBuilderBase(){

    }


    proc _addStatement(key,value){
        this._statements[key] = value;
    }

    proc Select(){

        if(this._statements_dim.member("select")){
            var stdata = this._statements["select"];
            stdata.append("*");
        }else{
            this._statements["select"] = new StatementData("select",["*"]);
        }
        return this;
    }
    proc Select(columns:[?D]string){
        if(this._statements_dim.member("select")){
            var stdata = this._statements["select"];
            stdata.append(columns);
        }else{
            this._statements["select"] = new StatementData("select",columns);
        }
        return this;
    }

    proc From(table){
        if(this._statements_dim.member("from")){
            var stdata = this._statements["from"];
            stdata.append(table);
        }else{
            this._statements["table"] = new StatementData("table",[table]);
        }
        return this;
    }

    proc Where(column:string, value, concat_op="AND"){
        return this.Where(column,"=",value,concat_op);
    }

    proc Where(column:string, op:string, value, concat_op="AND"){

        var ops:whereType = (column ,op, value,concat_op);
       
        if(this._statements_dim.member("where")){
            var stdata = this._statements["where"];
            stdata.append(ops);
        }else{
            this._statements["where"] = new StatementData("where",ops);
        }

        return this;
    }
    proc WhereIn(column:string, values:[?D]string ,concat_op="AND"){
        var ops:whereType = (column ,"IN", value,concat_op);
       
        if(this._statements_dim.member("whereIn")){
            var stdata = this._statements["whereIn"];
            stdata.append(ops);
        }else{
            this._statements["whereIn"] = new StatementData("whereIn",ops);
        }
        
        return this;
    }
    proc WhereNotIn( column:string, op:string, value,concat_op="AND"){
        
    }

    proc WhereNotNull( column:string,concat_op="AND"){

    }

    proc WhereBetween( column:string, op:string, value,concat_op="AND"){

    }

    proc orWhere( column:string, value){
        return this.Where( column, "=", value, "OR");
    }

    proc orWhere( column:string, op:string, value){
        return this.Where( column, op, value, "OR");
    }

    proc Count(){

    }
    proc Delete(){

    }

    proc OrderBy(column){
        if(this._statements_dim.member("orderByAsc")){
            var stdata = this._statements["orderByAsc"];
            stdata.append(column);
        }else{
            this._statements["orderByAsc"] = new StatementData("orderByAsc",column);
        }
        return this;
    }

    
    proc OrderBy(columns:[?D]string){
        if(this._statements_dim.member("orderByAsc")){
            var stdata = this._statements["orderByAsc"];
            stdata.append(columns);
        }else{
            this._statements["orderByAsc"] = new StatementData("orderByAsc",columns);
        }
        return this;
    }


    proc OrderByDesc(column){
        if(this._statements_dim.member("orderByDesc")){
            var stdata = this._statements["orderByDesc"];
            stdata.append(column);
        }else{
            this._statements["orderByDesc"] = new StatementData("orderByDesc",column);
        }
        
        return this;
    }

    proc OrderByDesc(columns:[?D]string){
        if(this._statements_dim.member("orderByDesc")){
            var stdata = this._statements["orderByDesc"];
            stdata.append(columns);
        }else{
            this._statements["orderByDesc"] = new StatementData("orderByDesc",columns);
        }
        return this;
    }
    proc GroupBy(column){
        if(this._statements_dim.member("groupBy")){
            var stdata = this._statements["groupBy"];
            stdata.append(column);
        }else{
            this._statements["groupBy"] = new StatementData("groupBy",column);
        }

        return this;
    }

    proc GroupBy(columns:[?D]string){
        if(this._statements_dim.member("groupBy")){
            var stdata = this._statements["groupBy"];
            stdata.append(columns);
        }else{
            this._statements["groupBy"] = new StatementData("groupBy",columns);
        }
        return this;
    }
    proc Limit(i:int){
        if(this._statements_dim.member("limit")){
            var stdata = this._statements["limit"];
            stdata.setData([i:string]);
        }else{
            this._statements["limit"] = new StatementData("limit",[i:string]);
        }   
        return this;
    }
    proc Offset(i:int){
        if(this._statements_dim.member("offset")){
            var stdata = this._statements["offset"];
            stdata.setData([i:string]);
        }else{
            this._statements["offset"] = new StatementData("offset",[i:string]);
        }
        return this;
    }

    proc toSql():string{
        return "";
    }

    proc Get(){
        
    }

    proc writeThis(f){
        try{
            for c in this._statements{
                f.writeln(c);
            }
        }catch{
            writeln("Error on write");
        }
    }

    proc _has(opname:string):bool{
        return this._statements_dim.member(opname);
    }

    proc _get(opname):StatementData{
        return this._statements[opname];
    }

    proc Insert(columns:[?D]string,  values:[?D2]string){
        
        var d:[{1..0}]string;

        d.push_back(columns);
        d.push_back(values);
        
        if(this._statements_dim.member("insert")){
            var stdata = this._statements["insert"];
            stdata.setData(d);
        }else{
            this._statements["insert"] = new StatementData("insert",d);
        }
        return this;

    }

    proc Insert(data:[?D]string){

    }


}




/*

`Connection` forwarding contract interface-like class.

*/
class Connection{
    forwarding var driver: ConnectionBase;
}
/*
`Connection` forwarding contract interface-like class.
*/
class Cursor{
    forwarding var cursor_drv: CursorBase;
}

class QueryBuilder{
    forwarding var query_driver: QueryBuilderBase;

    /*proc writeThis(f){
        this.query_driver.writeThis(f);
    }*/
}


}//end module