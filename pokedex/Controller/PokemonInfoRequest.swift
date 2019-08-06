//
//  PokemonInfoRequest.swift
//  pokedex
//
//  Created by Howard Chang on 7/20/19.
//  Copyright © 2019 Howard Chang. All rights reserved.
//

//import Foundation
//
//struct PokemonRequest {
//    var pokemon: Pokemon!
//    let resourceURL: URL
//
//        let resourceString = "https://pokeapi.co/api/v2/pokemon/\(pokemon.pokedexId)"
//        guard let resourceURL = URL(string: resourceString) else {fatalError()}
//        self.resourceURL = resourceURL
//    }
//
//    func getPokemonInfo(completion: @escaping(Result<Pokemon, Error>) -> Void) {
//        URLSession.shared.dataTask(with: resourceURL) { (data, response, err) in
//            guard let data = data else {return}
//
//            //            let dataAsString = String(data: data, encoding: .utf8)
//            do {
//                //                let pokemonArray = dataAsString as? Dictionary<String,String>
//                //                print(pokemonArray)
//                let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
//
//                print(pokemon.stats![0].stat)
//                for num in pokemon.stats! {
//                    if num.stat.name == "attack" {
//                        print(num.baseStat!)
//                    }
//                }
//                
//
//
//            } catch {
//                print(error)
//        }
//        }.resume()
//    }
//
//
//}
