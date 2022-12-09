/*
 *  dictionary_access_flag_manager.h
 *
 *  This file is part of NEST.
 *
 *  Copyright (C) 2004 The NEST Initiative
 *
 *  NEST is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  NEST is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with NEST.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef DICTIONARY_ACCESS_FLAG_MANAGER_H
#define DICTIONARY_ACCESS_FLAG_MANAGER_H

#include <map>
#include <string>
#include <unordered_set>

#include "dictionary.h"

/**
 * @brief Access flag manager for the dictionary class
 *
 * Manages access flags for dictionary keys and can check if all keys
 * in a dictionary has been accessed. Key access is not integrated into
 * the dictionary class to be able to keep the dictionary const.
 */
class DictionaryAccessFlagManager
{
private:
  using key_type_ = dictionary::key_type;
  std::map< const dictionary*, std::unordered_set< key_type_ > > access_flags_;

public:
  DictionaryAccessFlagManager() = default;
  ~DictionaryAccessFlagManager() = default;

  void init_access_flags( const dictionary& );
  void register_access( const dictionary&, const key_type_& );

  /**
   * @brief Check that all elements in a dictionary have been accessed.
   *
   * @param dict Dictionary to check
   * @param where Which function the error occurs in
   * @param what Which parameter triggers the error
   *
   */
  void all_accessed( const dictionary& dict, const std::string where, const std::string what ) const;

  /**
   * @brief Return whether the specified key has been accessed by the dictionary.
   *
   * @param dict Dictionary to check
   * @param key Key to check
   * @return true if key has been accessed
   * @return false if key has not been accessed
   */
  bool accessed( const dictionary& dict, const key_type_& key ) const;
};

inline void
DictionaryAccessFlagManager::init_access_flags( const dictionary& dict )
{
#pragma omp critical( init_access_flags )
  {
    access_flags_[ &dict ] = {};
  }
}

inline void
DictionaryAccessFlagManager::register_access( const dictionary& dict, const key_type_& key )
{
#pragma omp critical( register_access )
  {
    access_flags_[&dict ].insert( key );
  }
}

#endif // DICTIONARY_ACCESS_FLAG_MANAGER_H
