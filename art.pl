#!/usr/bin/perl

use strict;
use warnings;

my $key = $ARGV[0] if(defined($ARGV[0]));
# fuck, my fingers ache.
my %types = (
        "animals" => "aardvarks,amoeba,bats,bears,beavers,birds-(land),birds-(water),bisons,camels,cats,cows,deer,dogs,dolphins,elephants,fish,frogs,horses,marsupials,monkeys,moose,other-(land),other-(water),rabbits,rhinoceros,scorpions,spiders,wolves",
        "art-and-design" => "artists,borders,celtic,dividers,egyptian,escher,famous-paintings,fleur-de-lis,fractals,gender-symbols,geometries,mazes,mona-lisa,origamis,other,patterns,pentacles,sculptures",
        "books" => "alice-in-wonderland,books,dr-seuss,harry-potter,lord-of-the-rings,moomintroll,other,winnie-the-pooh",
        "buildings-and-places" => "alcatraz,bridges,buildings,castles,church,cities,fences,flags,houses,lighthouses,maps,other,temple,windmills",
        "cartoons" => "animaniacs,beavis-and-butt-head,betty-boop,casper,felix-the-cat,flintstones,inspector-gadget,jetsons,looney-tunes,mickey-mouse,mighty-mouse,mushroom,other,pink-panther,popeye,ren-and-stimpy,roger-rabbit,simpsons,smurfs,south-park,spongebob-squarepants,tiny-toon-adventures,two-stupid-dogs",
        "clothing-and-accessories" => "bikinis,bra,crowns,dresses,footwear,glasses,handwears,hats,nightwears,other,overalls,pants,shirts,skirts,umbrellas,underwear",
        "comics" => "alfred-e-neuman,archie,asterix,batman,bloom-county,calvin-and-hobbes,captain-america,dilbert,garfield,judge-dredd,lucky-luke,mafalda,other,peanuts,spiderman,superman,x-men",
        "computers" => "amiga,apple,atari,bug,computers,floppies,fonts,game-consoles,joysticks,keyboards,linux,mouse,other,smileys,sun-microsystems",
        "electronics" => "audio-equipment,blender,calculators,cameras,clocks,electronics,light-bulbs,other,phones,robots,stereos,televisions",
        "food-and-drinks" => "apples,bananas,beers,candies,chocolates,coffee-and-tea,drinks,ice-creams,other",
        "holiday-and-events" => "4th-of-july,birthdays,easter,fathers-day,fireworks,graduation,halloween,hanukkah,luck,mothers-day,new-year,other,saint-patricks-day,thanksgiving,valentine,wedding",
        "logos" => "amnesty-international,biohazards,caduceus,coca-cola,hello-kitty,jolly-roger,kool-aid,no-bs,no-smoking,other,peace,pillsbury-doughboy,playboy,recycle,television",
        "miscellaneous" => "abacuses,anchors,antennas,awards,badges,bones,bottles,boxes,brooms,buckets,candies,chains,cigarettes,diamonds,dice,dna,feathers,fire-extinguishers,handcuffs,hourglass,keys,kleenex,magnifying-glass,mailbox,medical,money,noose,other,playing-cards,signs,tools",
        "movies" => "alladin,bambi,beauty-and-the-beast,ghostbusters,ice-age,james-bond,lion-king,little-mermaid,other,peter-pan,pinocchio,pocahontas,red-dwarf,shrek,snow-white,spaceballs,star-wars,tinker-bell,toy-story,wallace-and-gromit",
        "music" => "musical-instruments,musical-notation,other,pianos",
        "mythology" => "centaurs,devils,dragons,fairies,fantasy,ghosts,grim-reapers,gryphon,mermaids,monsters,mythology,phoenix,skeletons,unicorns",
        "nature" => "beach,camping,clouds,deserts,islands,landscapes,lightning,mountains,other,rainbow,rains,snows,sun,sunset,tornado,waterfall",
        "people" => "babies,bathing,couples,faces,kiss,men,native-americans,other,sleeping,tribal-people,women",
        "plants" => "bonsai-trees,cactus,daffodils,dandelions,flowers,leaf,marijuana,mushroom,other,roses",
        "religion" => "angels,buddhism,christianity,crosses-and-crucifixes,hinduism,judaism,other,preachers,saints,yin-and-yang",
        "space" => "aliens,astronauts,moons,other,planetary-rovers,planets,satellites,spaceships,stars,telescopes",
        "sports-and-outdoors" => "baseball,basketball,billiards,bowling,boxing,bungee-jumping,chess,cycling,dancing,darts,fencing,fishing,football,golf,ice-hockey,ice-skating,logos,nba-logos,other,rodeo,scuba,skiing,soccer,surfing,swimming,tennis",
        "television" => "babylon-5,barney,bear-in-the-big-blue-house,dexters-laboratory,doctor-who,futurama,galaxy-quest,gumby-and-pokey,looney-tunes,muppets,other,pinky-and-the-brain,rugrats,sesame-street,star-trek,wallace-and-gromit,x-files",
        "toys" => "balloons,beanie-babies,dolls,other,pez,teddy-bears",
        "weapons" => "axes,bows-and-arrows,explosives,guillotines,guns,knives,other,shields,soldiers,swords",
        "vehicles" => "airplanes,bicycles,boats,busses,cars,choppers,motorcycles,navy,other,trains,trucks",
        "video-games" => "atomic-bomberman,creatures,hitman,lara-croft,max-payne,mortal-kombat,other,pacman,pokemon,sonic-the-hedgehog,zelda"
);

my @hashkeys = keys %types;
my $randomkey = $hashkeys[rand @hashkeys];
$randomkey = $key if(defined($key));
my $randomval = $types{$randomkey};
my @subtypes = split(',', $randomval);
$randomval = $subtypes[rand @subtypes];
my $page = `curl -s "http://www.ascii-code.com/ascii-art/$randomkey/$randomval.php"`;
my @arts = split(/<\/pre><\/div><div style=.*?<pre>/, $page);
my $drawing = $arts[rand @arts];
#$drawing = $arts[1] if($drawing eq $arts[0]);
#$drawing = $arts[-2] if($drawing eq $arts[-1]);
#$drawing =~ s/<\/div><div style="border-top:1px solid gray; margin:10px 0px; padding:10px 0px;">.*//s if($drawing eq $arts[-1]);
$drawing =~ /<pre>(.*)<\/pre>/;
$drawing =~ s/&gt/>/g;
$drawing =~ s/&lt/</g;
#$drawing =~ s/\s<strong>.*?<\/strong>.*?<pre>//;
#$drawing =~ s/<pre>//g;
#$drawing =~ s/<div>//g;
#$drawing =~ s/<\/div>//g;
#$drawing =~ s/<\/pre>//g;
print "$drawing\n";
