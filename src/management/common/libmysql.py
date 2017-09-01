# -*- coding: utf8 -*-

"""
desc:   A Friendly pymysql CURD Class
https://dev.mysql.com/doc/connector-python/en/connector-python-reference.html

SQL Injection Warning: pymysql.escape_string(value)
"""

import gevent, gevent.monkey
gevent.monkey.patch_all()
import pymysql

class NotSupportedError(Exception):
    pass

class NotConnectedError(Exception):
    pass

class MYSQL:
    # A Friendly pymysql Class, Provide CRUD functionality
    # conf sample: {"host":"127.0.0.1", "port":3306, "user": "root", "password": "", "db":"dbname"},
    def __init__(self, conf):
        self.__conn = None
        self.conf = conf
        self.conf["port"] = conf.get("port", 3306)
        self.conf["charset"] = conf.get("charset", "utf8")
        self.conf["cursorclass"] = pymysql.cursors.DictCursor
        self.connect()

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_tp, exc_val, exc_tb):
        self.disconnect()

    def __del__(self):
        self.disconnect()

    def is_connected(self):
        return self.__conn and self.__conn.open

    def connect(self):
        if not self.is_connected():
            self.__conn = pymysql.connect(**self.conf)

    def disconnect(self):
        if self.is_connected():
            self.__conn.close()

    def insert(self, table, data):
        """mysql insert() function"""
        if not self.is_connected():
            raise NotConnectedError

        with self.__conn.cursor() as cursor:
            params = self.join_field_value(data);
            sql = "INSERT INTO {table} SET {params}".format(table=table, params=params)

            result = cursor.execute(sql)
            self.__conn.commit() # not autocommit

            return result

    def delete(self, table, condition=None, limit=None):
        """mysql delete() function"""
        if not self.is_connected():
            raise NotConnectedError

        with self.__conn.cursor() as cursor:
            if not condition:
                where = '1';
            elif isinstance(condition, dict):
                where = self.join_field_value( condition, ' AND ' )
            else:
                where = condition

            limits = "LIMIT {limit}".format(limit=limit) if limit else ""
            sql = "DELETE FROM {table} WHERE {where} {limits}".format(
                table=table, where=where, limits=limits)

            result = cursor.execute(sql)
            self.__conn.commit() # not autocommit

            return result

    def update(self, table, data, condition=None):
        """mysql update() function"""
        if not self.is_connected():
            raise NotConnectedError

        with self.__conn.cursor() as cursor:
            params = self.join_field_value(data)
            if not condition:
                where = '1';
            elif isinstance(condition, dict):
                where = self.join_field_value( condition, ' AND ' )
            else:
                where = condition

            sql = "UPDATE {table} SET {params} WHERE {where}".format(
                table=table, params=params, where=where)

            result = cursor.execute(sql)
            self.__conn.commit() # not autocommit

            return result

    def count(self, table, condition=None):
        """count database record"""
        if not self.is_connected():
            raise NotConnectedError

        with self.__conn.cursor() as cursor:
            # WHERE CONDITION
            if not condition:
                where = '1';
            elif isinstance(condition, dict):
                where = self.join_field_value( condition, ' AND ' )
            else:
                where = condition

            # SELECT COUNT(1) as cnt
            sql = "SELECT COUNT(1) as cnt FROM {table} WHERE {where}".format(
                table=table, where=where)

            # EXECUTE SELECT COUNT sql
            cursor.execute(sql)

            # RETURN cnt RESULT
            return cursor.fetchone().get('cnt')

    def fetch(self, table, fields=None, condition=None, order=None, limit=None, fetchone=False):
        """mysql select() function"""
        if not self.is_connected():
            raise NotConnectedError

        with self.__conn.cursor() as cursor:
            # SELECT FIELDS
            if not fields:
                fields = '*'
            elif isinstance(fields, tuple) or isinstance(fields, list):
                fields = '`, `'.join(fields)
                fields = '`{fields}`'.format(fields=fields)
            else:
                fields = fields

            # WHERE CONDITION
            if not condition:
                where = '1';
            elif isinstance(condition, dict):
                where = self.join_field_value( condition, ' AND ' )
            else:
                where = condition

            # ORDER BY OPTIONS
            if not order:
                orderby = ''
            else:
                orderby = 'ORDER BY {order}'.format(order=order)

            # LIMIT NUMS
            limits = "LIMIT {limit}".format(limit=limit) if limit else ""
            sql = "SELECT {fields} FROM {table} WHERE {where} {orderby} {limits}".format(
                fields=fields,
                table=table,
                where=where,
                orderby=orderby,
                limits=limits)

            cursor.execute(sql)

            if fetchone:
                return cursor.fetchone()
            else:
                return cursor.fetchall()

    def query(self, sql, fetchone=False):
        if not self.is_connected():
            raise NotConnectedError

        with self.__conn.cursor() as cursor:
            cursor.execute(sql)
            opmeths = {'select': cursor.fetchone if fetchone else cursor.fetchall,
                       'insert': self.__conn.commit,
                       'update': self.__conn.commit,
                       'delete': self.__conn.commit}
            method = opmeths.get(sql.split()[0].lower())
            if not method:
                raise NotSupportedError
        return method()

    def join_field_value(self, data, glue = ', '):
        sql = comma = ''
        for key, value in data.iteritems():
            if isinstance(value, str):
                value = pymysql.escape_string(value)
            sql +=  "{}`{}` = '{}'".format(comma, key, value)
            comma = glue
        return sql

class QuickSQL:
    def insert(self, dbconf, table, data):
        res = None
        try:
            with MYSQL(dbconf) as db:
                res = db.insert(table, data)
        except Exception, e:
            print e
        return res

    def delete(self, dbconf, table, condition=None, limit=None):
        res = None
        try:
            with MYSQL(dbconf) as db:
                res = db.delete(table, condition, limit)
        except Exception, e:
            print e
        return res

    def update(self, dbconf, table, data, condition=None):
        res = None
        try:
            with MYSQL(dbconf) as db:
                res = db.update(table, data, condition)
        except Exception, e:
            print e
        return res

    def count(self, dbconf, table, condition=None):
        res = None
        try:
            with MYSQL(dbconf) as db:
                res = db.count(table, condition)
        except Exception, e:
            print e
        return res

    def fetch(self, dbconf, table, fields=None, condition=None, order=None, limit=None, fetchone=False):
        res = None
        try:
            with MYSQL(dbconf) as db:
                res = db.fetch(table, fields, condition, order, limit, fetchone)
                if res == (): res = []
        except Exception, e:
            print e
        return res

    def query(self, dbconf, sql, fetchone=False):
        res = None
        # try:
        with MYSQL(dbconf) as db:
            res = db.query(sql, fetchone)
        # except Exception, e:
            # print e
        return res

class GenSQL:
    def count(self, table, condition=None):
        # WHERE CONDITION
        if not condition:
            where = '1';
        elif isinstance(condition, dict):
            where = self.join_field_value( condition, ' AND ' )
        else:
            where = condition

        # SELECT COUNT(1) as cnt
        sql = "SELECT COUNT(1) as cnt FROM {table} WHERE {where}".format(
            table=table, where=where)

        return sql

    def select(self, table, fields=None, condition=None, order=None, limit=None):
        # SELECT FIELDS
        if not fields:
            fields = '*'
        elif isinstance(fields, tuple) or isinstance(fields, list):
            fields = '`, `'.join(fields)
            fields = '`{fields}`'.format(fields=fields)
        else:
            fields = fields

        # WHERE CONDITION
        if not condition:
            where = '1';
        elif isinstance(condition, dict):
            where = self.join_field_value( condition, ' AND ' )
        else:
            where = condition

        # ORDER BY OPTIONS
        if not order:
            orderby = ''
        else:
            orderby = 'ORDER BY {order}'.format(order=order)

        # LIMIT NUMS
        limits = "LIMIT {limit}".format(limit=limit) if limit else ""
        sql = "SELECT {fields} FROM {table} WHERE {where} {orderby} {limits}".format(
            fields=fields,
            table=table,
            where=where,
            orderby=orderby,
            limits=limits)
        return sql

    def join_field_value(self, data, glue = ', '):
        sql = comma = ''
        for key, value in data.iteritems():
            if isinstance(value, str):
                value = pymysql.escape_string(value)
            sql +=  "{}`{}` = '{}'".format(comma, key, value)
            comma = glue
        return sql

def concurrent(ctxs):
    eventlets = [gevent.spawn(*ctx) for ctx in ctxs]
    gevent.joinall(eventlets)
    results = [eventlet.value for eventlet in eventlets]
    return results

if __name__ == '__main__':
    tables = ['aaa', 'bbb', 'ccc']
    fields = ['a', 'b']
    condition = {'a':1, 'b':0}
    order = 'a desc'

    sqls = [GenSQL().count(table, condition) for table in tables]
    for sql in sqls: print sql

    sqls = [GenSQL().select(table, fields, condition, order) for table in tables]
    for sql in sqls: print sql

    conf = {"host":"127.0.0.1", "port":3306, "user":"root", "password":"", "db":"mysql"}
    print QuickSQL().count(conf, 'user')
    print QuickSQL().fetch(conf, 'user', ['Host', 'User'])