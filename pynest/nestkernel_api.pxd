# -*- coding: utf-8 -*-
#
# ll_api.pxd
#
# This file is part of NEST.
#
# Copyright (C) 2004 The NEST Initiative
#
# NEST is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# NEST is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NEST.  If not, see <http://www.gnu.org/licenses/>.

from libcpp cimport bool as cbool

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair

from cpython.ref cimport PyObject

cdef extern from "node_collection.h" namespace "nest":
    cppclass NodeCollectionPTR:
        NodeCollectionPTR()

    NodeCollectionPTR operator+(NodeCollectionPTR, NodeCollectionPTR)

cdef extern from "node_collection.h":
    cppclass NodeCollectionDatum:
        NodeCollectionDatum(const NodeCollectionDatum&)

    cppclass NodeCollectionIteratorDatum:
        NodeCollectionIteratorDatum(const NodeCollectionIteratorDatum&)

cdef extern from "dictionary.h" namespace "boost":
    cppclass any:
        any()
        any& operator=[T](T&)
    T any_cast[T](any& operand)

cdef extern from "dictionary.h":
    cppclass dictionary:
        dictionary()
        # ctypedef key_type
        # ctypedef mapped_type
        any& operator[](const string&)
        cppclass const_iterator:
            pair[string, any]& operator*()
            const_iterator operator++()
            bint operator==(const const_iterator&)
            bint operator!=(const const_iterator&)
        const_iterator begin()
        const_iterator end()
    string debug_type(const any&)
    cbool is_int(const any&)
    cbool is_long(const any&)
    cbool is_size_t(const any&)
    cbool is_double(const any&)
    cbool is_bool(const any&)
    cbool is_string(const any&)
    cbool is_int_vector(const any&)
    cbool is_double_vector(const any&)
    cbool is_string_vector(const any&)
    cbool is_any_vector(const any&)
    cbool is_dict(const any&)

cdef extern from "nest.h" namespace "nest":
    void init_nest( int* argc, char** argv[] )
    void reset_kernel()
    NodeCollectionPTR create( const string model_name, const long n ) except +

    NodeCollectionPTR make_nodecollection( const vector[size_t] node_ids ) except +

    cbool equal( const NodeCollectionPTR lhs, const NodeCollectionPTR rhs ) except +
    cbool contains( const NodeCollectionPTR nc, const size_t node_id ) except +

    NodeCollectionPTR slice_nc( const NodeCollectionPTR nc, long start, long stop, long step ) except +
    void connect(NodeCollectionPTR sources,
                 NodeCollectionPTR targets,
                 const dictionary& connectivity,
                 const vector[dictionary]& synapse_params ) except +
    string pprint_to_string( NodeCollectionPTR nc )
    size_t nc_size( NodeCollectionPTR nc )
    dictionary get_kernel_status()
    void set_kernel_status( const dictionary& ) except +
    dictionary get_nc_status( NodeCollectionPTR nc )
    void set_nc_status( NodeCollectionPTR nc, dictionary& params ) except +
    void simulate( const double& t )

cdef extern from "nest.h" namespace "nest":
    NodeCollectionPTR node_collection_array_index(NodeCollectionPTR node_collection, const long* array, unsigned long n) except +
    NodeCollectionPTR node_collection_array_index(NodeCollectionPTR node_collection, const cbool* array, unsigned long n) except +
    void connect_arrays( long* sources, long* targets, double* weights, double* delays, vector[string]& p_keys, double* p_values, size_t n, string syn_model ) except +