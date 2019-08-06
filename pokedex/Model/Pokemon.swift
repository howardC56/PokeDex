//
//  Pokemon.swift
//  pokedex
//
//  Created by Howard Chang on 6/27/19.
//  Copyright © 2019 Howard Chang. All rights reserved.
//

import Foundation


// Pokemon evolution
struct PokeName: Decodable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}

struct Species: Decodable {
    var species: PokeName
    var evolvesTo: [Species]?
    
    enum CodingKeys: String, CodingKey {
        case species = "species"
        case evolvesTo = "evolves_to"
    }
}

struct Evolves: Decodable {
    var evolvesTo: [Species]?
    
    enum CodingKeys: String, CodingKey {
        case evolvesTo = "evolves_to"
    }
}

struct Chain: Decodable {
    var chain: [Evolves]?
    var species: PokeName
    enum CodingKeys: String, CodingKey {
        case chain = "chain"
        case species = "species"
    }
}

// pokemon evolution url
struct Url: Decodable {
    var url: String
    
    enum CodingKeys: String, CodingKey {
    case url = "url"
    }
}

// Pokemon Description
struct VersionName: Decodable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}

struct English: Decodable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}

struct FlavorText: Decodable {
    var flavorText: String?
    var language: English
    var version: VersionName
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language = "language"
        case version = "version"
    }
}

// Pokemon attack/defense
struct Stats: Decodable {
    var baseStat: Int?
    var stat: StatName
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat = "stat"
    }
    
}

struct StatName: Decodable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
    
}

// Pokemon Type
struct Name: Decodable {
    var TypeName: String?
    
    enum CodingKeys: String, CodingKey {
        case TypeName = "name"
    }
}



struct Type: Decodable {
    var type: Name?
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
    }
}



struct Pokemon: Decodable {
    var pokeName: String?
    private var pokePokedexId: Int?
    var description: [FlavorText]?
    var types: [Type]?
    var stats: [Stats]?
    var height: Int?
    var weight: Int?
    var attack: Int?
    var defense: Int?
    var evolutionChainURL: Url?
    var evolutionDetails: Chain?
    private var _pokemonURL: String?
    
   
    
    enum CodingKeys: String, CodingKey {
        case types = "types"
        case height = "height"
        case weight = "weight"
        case stats = "stats"
        case attack = "attack"
        case defense = "defense"
        case description = "flavor_text_entries"
        case evolutionChainURL = "evolution_chain"
        case evolutionDetails = "chain"
    }
    
    
    
    
    var name: String {
        return pokeName!
    }
    
    var pokedexId: Int {
        return pokePokedexId!
    }
    
    init(name: String, pokedexId: Int) {
        self.pokeName = name
        self.pokePokedexId = pokedexId
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
        
    }
    

    
    
}
