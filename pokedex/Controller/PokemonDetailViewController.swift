import UIKit

class PokemonDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EvolutionUICollectionViewCell", for: indexPath) as? EvolutionUICollectionViewCell {
            let poke: Pokemon!
            poke = evolutionArray[indexPath.row]
            cell.configureCell(pokemon: poke)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var poke: Pokemon!
        pokemon = evolutionArray[indexPath.row]
        
        let newVC = PokemonDetailViewController()
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "PokemonDetailViewController")
//        navigationController?.pushViewController(viewController, animated: true)
//        print(pokemon)
        
        let nav = UINavigationController(rootViewController: self)
        UIApplication.shared.keyWindow?.rootViewController = nav
        nav.pushViewController(newVC, animated: true)
        performSegue(withIdentifier: "PokemonDetailViewController", sender: pokemon)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evolutionArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .mainColor()
        navigationController?.navigationBar.barStyle = .black
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mainPokemonImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var defenseLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var pokedexIdLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var evolutions: UICollectionView!
    //@IBOutlet weak var nextEvoImg: UIImageView!
    @IBOutlet weak var evoLabel: UILabel!
//    @IBOutlet weak var bioMoves: UISegmentedControl! = {
//        let control = UISegmentedControl(items: items)
//        control.addTarget(self, action: #selector(handleSegmentedControlValueChanged(_:)), for: .valueChanged)
//    }
//
//    @objc fileprivate func handleSegmentedControlValueChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            return
//        case 1:
//            return
//        default:
//            return
//        }
//    }
    var evolutionArray = [Pokemon]()
    //let items = ["Bio", "Moves"]
    var pokemon: Pokemon!
    var pokemonDescript: Pokemon!
    var evoUrl: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setRightNavigationButton()
        configureNavigationBar()
        navigationItem.title = pokemon.name.capitalized
        let img = UIImage(named: "\(pokemon.pokedexId)")
        mainPokemonImage.image = img
        pokedexIdLabel.text = "\(pokemon.pokedexId)"
        evolutions.dataSource = self
        evolutions.delegate = self
        DispatchQueue.main.async{ [weak self] in
            self?.fetchPokemonJson{(res) in
                switch res {
                case .success(let pokemon):
                    self?.fetchPokemonDescriptionJson{(res) in
                        switch res {
                        case .success(let pokemon):
                            self?.fetchPokemonEvoData{(res) in
                                switch res {
                                case .success(let pokemon):
                                    self!.evolutions.reloadData()
                                    case .failure(let error):
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                  case .failure(let error):
                    print(error)
                }
            }
        }
        }
 
    @objc func home() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchPokemonDescriptionJson(completion: @escaping (Result<Pokemon, Error>) -> Void) {
            let descriptionUrlString = "https://pokeapi.co/api/v2/pokemon-species/\(pokemon.pokedexId)"
            guard let descriptionUrl = URL(string: descriptionUrlString) else {return}
                URLSession.shared.dataTask(with: descriptionUrl) { (data, response, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    do {
                        var pokemonDescript = try JSONDecoder().decode(Pokemon.self, from: data!)
                        DispatchQueue.main.async { [weak self] in
                            for version in pokemonDescript.description! {
                                if version.version.name == "emerald", version.language.name == "en" {
                                   self!.descriptionLabel.text = version.flavorText
                                } else if version.version.name == "ultra-sun" , version.language.name == "en" {
                                    self!.descriptionLabel.text = version.flavorText
                                } else if version.version.name == "alpha-sapphire" , version.language.name == "en" {
                                    self!.descriptionLabel.text = version.flavorText
                                }
                            }
                            self?.evoUrl = pokemonDescript.evolutionChainURL!.url
                            completion(.success(pokemonDescript))
                        }
                    } catch let jsonError {
                        completion(.failure(jsonError))
                    }
                }.resume()
            }
    
    private func setRightNavigationButton() {
        let rightButton = UIButton(type: .system)
        rightButton.setImage(UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
        //rightButton.frame = CGRect(x: 0, y: 0, width: 20, height: 30)
        //rightButton.contentMode = .scaleAspectFit
        //rightButton.clipsToBounds = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.addTarget(self, action: #selector(home), for: .touchUpInside)
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(home))
    }
    
    func fetchPokemonJson(completion: @escaping (Result<Pokemon, Error>) -> Void) {
        let jsonUrlString = "https://pokeapi.co/api/v2/pokemon/\(pokemon.pokedexId)"
        guard let url = URL(string: jsonUrlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
               var pokemon = try JSONDecoder().decode(Pokemon.self, from: data!)
                DispatchQueue.main.async { [weak self] in
                    self?.weightLabel.text = "\(pokemon.weight!)"
                    self?.heightLabel.text = "\(pokemon.height!)"
                    for num in pokemon.stats! {
                        if num.stat.name == "attack" {
                            pokemon.attack = num.baseStat!
                            self?.attackLabel.text = "\(pokemon.attack!)"
                        }
                        }
                    for num in pokemon.stats! {
                        if num.stat.name == "defense" {
                            pokemon.defense = num.baseStat!
                            self?.defenseLabel.text = "\(pokemon.defense!)"
                        }
                    }
                    if pokemon.types!.count > 1 {
                       self?.typeLabel.text = "\(pokemon.types![0].type!.typeName!.capitalized) / \(pokemon.types![1].type!.typeName!.capitalized)"
                        } else {
                        self?.typeLabel.text = "\(pokemon.types![0].type!.typeName!.capitalized)"
                    }
                    completion(.success(pokemon))
                }
                } catch let jsonError {
                completion(.failure(jsonError))
            }
        }.resume()
    }
    
    func fetchPokemonEvoData (completion: @escaping (Result<Pokemon, Error>) -> Void) {
        let evoJsonString = evoUrl
        guard let evoUrl = URL(string: evoJsonString) else {return}
            URLSession.shared.dataTask(with: evoUrl) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                do {
                    var pokemonEvo = try JSONDecoder().decode(Pokemon.self, from: data!)
                    DispatchQueue.main.async { [weak self] in
                        if self?.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.species.name && (pokemonEvo.evolutionDetails?.evolvesTo!.isEmpty)! {
                            self?.evoLabel.text = "Next Evolution: None"
                            //self?.nextEvoImg.isHidden = true
                            } else if self!.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.species.name && (pokemonEvo.evolutionDetails?.evolvesTo!.count)! == 1 {
                           self?.evoLabel.text = "Next Evolution: \(pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.name!.capitalized)"
                            if let url = pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.url {
                                let newStr = url.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                let newEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                pokemonEvo.nextEvoId = newEvoId
                            }
                            let nextEvoPokemon = Pokemon(name: "\(pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.name!)", pokedexId: Int(pokemonEvo.nextEvoId!)!)
                            self!.evolutionArray.append(nextEvoPokemon)
                            
                            //self?.nextEvoImg.image = UIImage(named: pokemonEvo.nextEvoId!)
                            } else if self!.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.name && (pokemonEvo.evolutionDetails?.evolvesTo![0].nextEvolvesTo!.count)! == 1 {
                            self?.evoLabel.text = "Next Evolution: \(pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![0].nextSpecies!.name!.capitalized)"
                            if let url = pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![0].nextSpecies!.url {
                                let newStr = url.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                let newEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                pokemonEvo.nextEvoId = newEvoId
                            }
                            let nextEvoPokemon = Pokemon(name: "\(pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![0].nextSpecies!.name!)", pokedexId: Int(pokemonEvo.nextEvoId!)!)
                            self!.evolutionArray.append(nextEvoPokemon)
                            //self?.nextEvoImg.image = UIImage(named: pokemonEvo.nextEvoId!)
                            } else if self!.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.species.name, (pokemonEvo.evolutionDetails?.evolvesTo!.count)! > 1 {
                            self?.evoLabel.text = "Next Evolution: Multiple Choices"
                            for each in 0..<(pokemonEvo.evolutionDetails!.evolvesTo!.count) {
                                if let url = pokemonEvo.evolutionDetails!.evolvesTo![each].nextSpecies!.url {
                                    let newStr = url.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                    let newEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                    pokemonEvo.nextEvoId = newEvoId
                                }
                                let nextEvoPokemon = Pokemon(name: "\(pokemonEvo.evolutionDetails!.evolvesTo![each].nextSpecies!.name!)", pokedexId: Int(pokemonEvo.nextEvoId!)!)
                                self!.evolutionArray.append(nextEvoPokemon)
                            }
                            } else if self!.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.name, (pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo!.count) > 1 {
                            self?.evoLabel.text = "Next Evolution: Multiple Choices"
                            for each in 0..<(pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo!.count){
                                if let url = pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![each].nextSpecies!.url {
                                    let newStr = url.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                    let newEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                    pokemonEvo.nextEvoId = newEvoId
                                }
                                let nextEvoPokemon = Pokemon(name: "\(pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![each].nextSpecies!.name!)", pokedexId: Int(pokemonEvo.nextEvoId!)!)
                                self!.evolutionArray.append(nextEvoPokemon)
                            }
                            } else {
                            self?.evoLabel.text = "Next Evolution: None"
                            //self?.nextEvoImg.isHidden = true
                        }
                        completion(.success(pokemonEvo))
                    }
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
    }.resume()
}

@IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokemonDetailViewController" {
            if let detailsViewController = segue.destination as? PokemonDetailViewController {
                if let poke = sender as? Pokemon {
                    detailsViewController.pokemon = poke
                }
            }
        }
    }
}

