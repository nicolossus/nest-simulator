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
from libcpp.deque cimport deque
from libcpp.utility cimport pair
from libcpp.memory cimport shared_ptr


cdef extern from "dictionary.h" namespace "boost":
    cppclass any:
        any()
        any& operator=[T](T&)
    T any_cast[T](any& operand)

cdef extern from "dictionary.h":
    cppclass dictionary:
        dictionary()
        any& operator[](const string&)
        cppclass const_iterator:
            pair[string, any]& operator*()
            const_iterator operator++()
            bint operator==(const const_iterator&)
            bint operator!=(const const_iterator&)
        const_iterator begin()
        const_iterator end()
    string debug_type(const any&)
    string debug_dict_types(const dictionary&)
    cbool is_type[T](const any&)

cdef extern from "connection_id.h" namespace "nest":
    cppclass ConnectionID:
        ConnectionID()

cdef extern from "node_collection.h" namespace "nest":
    cppclass NodeCollectionPTR:
        NodeCollectionPTR()

    NodeCollectionPTR operator+(NodeCollectionPTR, NodeCollectionPTR) except +

cdef extern from "node_collection.h":
    cppclass NodeCollectionDatum:
        NodeCollectionDatum(const NodeCollectionDatum&)

    cppclass NodeCollectionIteratorDatum:
        NodeCollectionIteratorDatum(const NodeCollectionIteratorDatum&)

cdef extern from "parameter.h" namespace "nest":
    cppclass Parameter:
        Parameter()
    shared_ptr[Parameter] multiply_parameter(const shared_ptr[Parameter] first, const shared_ptr[Parameter] second) except +
    shared_ptr[Parameter] divide_parameter(const shared_ptr[Parameter] first, const shared_ptr[Parameter] second) except +
    shared_ptr[Parameter] add_parameter(const shared_ptr[Parameter] first, const shared_ptr[Parameter] second) except +
    shared_ptr[Parameter] subtract_parameter(const shared_ptr[Parameter] first, const shared_ptr[Parameter] second) except +
    shared_ptr[Parameter] compare_parameter(const shared_ptr[Parameter] first, const shared_ptr[Parameter] second, const dictionary& d) except +
    shared_ptr[Parameter] conditional_parameter(const shared_ptr[Parameter] condition, const shared_ptr[Parameter] if_true, const shared_ptr[Parameter] if_false) except +
    shared_ptr[Parameter] min_parameter(const shared_ptr[Parameter] parameter, const double other) except +
    shared_ptr[Parameter] max_parameter(const shared_ptr[Parameter] parameter, const double other) except +
    shared_ptr[Parameter] redraw_parameter(const shared_ptr[Parameter] parameter, const double min, const double max) except +
    shared_ptr[Parameter] exp_parameter(const shared_ptr[Parameter] parameter) except +
    shared_ptr[Parameter] sin_parameter(const shared_ptr[Parameter] parameter) except +
    shared_ptr[Parameter] cos_parameter(const shared_ptr[Parameter] parameter) except +
    shared_ptr[Parameter] pow_parameter(const shared_ptr[Parameter] parameter, const double exponent) except +

    shared_ptr[Parameter] dimension_parameter(const shared_ptr[Parameter] x, const shared_ptr[Parameter] y) except +
    shared_ptr[Parameter] dimension_parameter(const shared_ptr[Parameter] x, const shared_ptr[Parameter] y, const shared_ptr[Parameter] z) except +

cdef extern from "nest.h" namespace "nest":
    void init_nest( int* argc, char** argv[] )
    void reset_kernel()
    NodeCollectionPTR create( const string model_name, const long n ) except +
    NodeCollectionPTR create_spatial( const dictionary& )

    NodeCollectionPTR make_nodecollection( const vector[size_t] node_ids ) except +

    cbool equal( const NodeCollectionPTR lhs, const NodeCollectionPTR rhs ) except +
    cbool contains( const NodeCollectionPTR nc, const size_t node_id ) except +
    long find( const NodeCollectionPTR nc, size_t node_id ) except +
    dictionary get_metadata( const NodeCollectionPTR nc ) except +

    NodeCollectionPTR slice_nc( const NodeCollectionPTR nc, long start, long stop, long step ) except +
    void connect(NodeCollectionPTR sources,
                 NodeCollectionPTR targets,
                 const dictionary& connectivity,
                 const vector[dictionary]& synapse_params ) except +
    int get_rank() except +
    int get_num_mpi_processes() except +
    string print_nodes_to_string()
    string pprint_to_string( NodeCollectionPTR nc ) except +
    size_t nc_size( NodeCollectionPTR nc ) except +
    dictionary get_modeldict() except +
    dictionary get_synapsedict() except +
    dictionary get_kernel_status() except +
    dictionary get_model_defaults( const string& ) except +
    NodeCollectionPTR get_nodes( const dictionary& params, const cbool local_only ) except +
    deque[ConnectionID] get_connections( const dictionary& dict ) except +
    void set_kernel_status( const dictionary& ) except +
    dictionary get_nc_status( NodeCollectionPTR nc ) except +
    void set_nc_status( NodeCollectionPTR nc, dictionary& params ) except +
    vector[dictionary] get_connection_status(const deque[ConnectionID]&) except +
    void set_connection_status(const deque[ConnectionID]&, const dictionary&) except +
    void set_connection_status(const deque[ConnectionID]&, const vector[dictionary]&) except +
    void simulate( const double& t ) except +
    void prepare() except +
    void run( const double& t ) except +
    void cleanup() except +
    shared_ptr[Parameter] create_parameter( const dictionary& param_dict ) except +
    double get_value( const shared_ptr[Parameter]& param ) except +
    cbool is_spatial( const shared_ptr[Parameter]& param ) except +

    NodeCollectionPTR node_collection_array_index(NodeCollectionPTR node_collection, const long* array, unsigned long n) except +
    NodeCollectionPTR node_collection_array_index(NodeCollectionPTR node_collection, const cbool* array, unsigned long n) except +
    void connect_arrays( long* sources, long* targets, double* weights, double* delays, vector[string]& p_keys, double* p_values, size_t n, string syn_model ) except +