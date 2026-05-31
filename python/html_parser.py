from bs4 import BeautifulSoup, Tag
import json
import re
import os

OUTPUT_DIR = "output"
RESULT_FILE = "units.json"

all_units = {}

def parse_html(html_path):

    with open(html_path, 'r', encoding='utf-8') as file:
        content = file.read()

    soup = BeautifulSoup(content, "html.parser")

    # =====================================================
    # DETERMINE CARD TYPE
    # =====================================================

    type_el = soup.find(
        id=lambda value: value and "largeCardTypeInfo" in value
    )

    raw_card_type = ""

    if type_el:
        raw_card_type = type_el.get_text(
            " ",
            strip=True
        ).upper()

    normalized_type = normalize_card_type(
        raw_card_type, soup
    )

    print(f"Detected card type: {normalized_type}")

    # =====================================================
    # SWITCH CASE
    # =====================================================

    match normalized_type:

        case "BYSTANDER":
            return parse_bystander(soup)

        case "EQUIPMENT":
            return parse_equipment(soup)

        case "MAP":
            return parse_map(soup)

        case "TERRAIN":
            return parse_terrain(soup)

        case "ONE_SHOT":
            return parse_one_shot(soup)

        case "SPECIAL_OBJECT":
            return parse_special_object(soup)

        case "POSSESSOR":
            return parse_possessor(soup)

        case "OBJECT":
             return parse_terrain(soup)
        
        case "TERRAIN_MARKER":
            return parse_terrain_marker(soup)
        
        case _:
            return parse_figure(soup)

def parse_figure(soup):

    # process improved movement and targeting
    specialPowersDescriptions = [
        el for el in soup.find_all(class_="largeCardSpecialPowerDescription")
    ]

    # process "KO" image
    for el in specialPowersDescriptions:
        for ko in el.find_all(class_="specialPowerEmbedKO"):
            ko.parent.replace_with(" KO'd ")

    # process DICE embedded in abilities
    for el in specialPowersDescriptions:
        for die in el.find_all(class_="specialPowerEmbedDie"):
            icon = die.find("i")
            if icon:
                classes = icon.get("class", [])
                for cls in classes:
                    match = re.search(r"d6-(\d)", cls)
                    if match:
                        die.parent.replace_with(f" {match.group(1)} ")
                        break

    # process "set" image
    for el in specialPowersDescriptions:
        for embed in el.find_all(class_="specialPowerEmbed"):
            label = embed.get("aria-label")
            img = embed.find("img")

            if label and img and "/images/set/" in img.get("src", ""):
                embed.parent.replace_with(f" {label} Set ")

    # find targets
    for el in specialPowersDescriptions:
        children = list(el.children)
        bolt_groups = []

        for child in children:
            if isinstance(child, Tag):
                img = child.find("img")

                if img and "bolt.svg" in img.get("src", ""):
                    bolt_groups.append(child)
                else:
                    if bolt_groups:
                        count = len(bolt_groups)
                        bolt_groups[0].replace_with(f" {count} targets ")

                        for group in bolt_groups[1:]:
                            group.decompose()

                        bolt_groups = []

        if bolt_groups:
            count = len(bolt_groups)
            bolt_groups[0].replace_with(f" {count} targets ")

            for group in bolt_groups[1:]:
                group.decompose()

    # embedded avengers
    for el in specialPowersDescriptions:
        for embed in el.find_all(class_="specialPowerEmbed"):
            img = embed.find("img")
            label = embed.get("aria-label")

            if img and label and "/images/ta/" in img.get("src", ""):
                bs = BeautifulSoup(label, "html.parser")
                name = bs.b.get_text(strip=True)
                embed.parent.replace_with(f" {name} ")

    # improved abilities
    for el in specialPowersDescriptions:
        for group in el.find_all(class_="specialPowerEmbedGroup"):
            embeds = group.find_all(class_="specialPowerEmbed")

            for embed in embeds:
                img = embed.find("img")
                title = embed.get("data-mdb-original-title")

                if img and title and "/images/imp/" in img.get("src", ""):
                    bs = BeautifulSoup(title, "html.parser")

                    name = bs.b.get_text(strip=True)

                    description = (
                        bs.get_text(" ", strip=True)
                        .replace(name, "", 1)
                        .lstrip(": ")
                        .strip()
                    )

                    group.replace_with(
                        f" {name}: {description} "
                    )
                    break

    # generic embeds
    for el in specialPowersDescriptions:
        for embed in el.find_all(class_="specialPowerEmbed"):
            img = embed.find("img")
            title = embed.get("data-mdb-original-title")

            if img and title:
                bs = BeautifulSoup(title, "html.parser")
                name = bs.b.get_text(strip=True)
                embed.parent.replace_with(f" {name} ")

    # =========================================================
    # SHORT KEY MAP
    # =========================================================
    #
    # fn  = figureName
    # ta  = teamAbilities
    # kw  = keywords
    # spt = specialPowersTypes
    # spn = specialPowersNames
    # spd = specialPowersDescriptions
    # pv  = pointValues
    # ia  = improvedAbilities
    # ian = improvedAbility.name
    # iad = improvedAbility.description
    # r   = range
    # t   = targets
    # ss  = statSymbols
    #
    # mca = movementClixAbilities
    # mcv = movementClixValue
    #
    # aca = attackClixAbilities
    # acv = attackClixValue
    #
    # dca = defenseClixAbilities
    # dcv = defenseClixValue
    #
    # gca = damageClixAbilities
    # gcv = damageClixValue
    #
    # dim = dimension
    #
    # =========================================================
    result = {
        "fn": soup.find(id="largeCardName").string.strip(),

        "ta": [
            BeautifulSoup(value, "html.parser").b.get_text(strip=True)
            for el in soup.find_all(class_="largeCardTeamAbility")
            if (value := el.get("aria-label"))
        ],

        "kw": [
            el.get_text(strip=True)
            for el in soup.find_all(class_="largeCardKeyword")[1:]
        ],

        "spt": [
            el.find_all("img")[1]["src"]
            .split("/")[-1]
            .replace(".svg", "")

            for el in soup.find_all(class_="specialPowerIcon")
        ],

        "spn": [
            el.get_text(strip=True)
            for el in soup.find_all(class_="largeCardSpecialPowerName")
        ],

        "spd": [
            el.get_text(" ", strip=True)
            for el in specialPowersDescriptions
        ],

        "pv": [
            int(el.get_text(strip=True))
            for el in soup.find_all(class_="largeCardPointValue")
        ],

        "ia": [
            {
                "ian": (
                    bs := BeautifulSoup(value, "html.parser")
                ).b.get_text(strip=True),

                "iad": bs.get_text(strip=True)
                .replace(bs.b.get_text(strip=True), "", 1)
                .lstrip(": ")
                .strip()
            }

            for el in soup.find_all(class_="largeCardImprovedAbility")

            if (value := el.get("aria-label")) is not None
        ],

        "r": int(
            soup.find_all(class_="largeCardRange")[0]
            .get_text(strip=True)
        ),

        "t": len(soup.find_all(class_="largeCardBolt")),

        "ss": [
            el["src"].split("/")[-1].replace(".svg", "")
            for el in soup.find_all(class_="largeCardCombatSymbolImg")
        ],

        "mca": [
            BeautifulSoup(value, "html.parser").b.get_text(strip=True)
            if value != "NONE" else "NONE"

            for el in soup.find_all(class_="largeCardDialRow")[1]
            .find_all(class_="dialEntry")

            for value in [el.get("data-mdb-original-title", "NONE")]
        ],

        "mcv": [
            int(el.find("div").get_text(strip=True))

            for el in soup.find_all(class_="largeCardDialRow")[1]
            .find_all(class_="dialEntry")
        ],

        "aca": [
            BeautifulSoup(value, "html.parser").b.get_text(strip=True)
            if value != "NONE" else "NONE"

            for el in soup.find_all(class_="largeCardDialRow")[2]
            .find_all(class_="dialEntry")

            for value in [el.get("data-mdb-original-title", "NONE")]
        ],

        "acv": [
            int(el.find("div").get_text(strip=True))

            for el in soup.find_all(class_="largeCardDialRow")[2]
            .find_all(class_="dialEntry")
        ],

        "dca": [
            BeautifulSoup(value, "html.parser").b.get_text(strip=True)
            if value != "NONE" else "NONE"

            for el in soup.find_all(class_="largeCardDialRow")[3]
            .find_all(class_="dialEntry")

            for value in [el.get("data-mdb-original-title", "NONE")]
        ],

        "dcv": [
            int(el.find("div").get_text(strip=True))

            for el in soup.find_all(class_="largeCardDialRow")[3]
            .find_all(class_="dialEntry")
        ],

        "gca": [
            BeautifulSoup(value, "html.parser").b.get_text(strip=True)
            if value != "NONE" else "NONE"

            for el in soup.find_all(class_="largeCardDialRow")[4]
            .find_all(class_="dialEntry")

            for value in [el.get("data-mdb-original-title", "NONE")]
        ],

        "gcv": [
            int(el.find("div").get_text(strip=True))

            for el in soup.find_all(class_="largeCardDialRow")[4]
            .find_all(class_="dialEntry")
        ],

        "dim": (
            soup.find(class_="cardDimensionsOval").get_text(strip=True)
            if soup.find(class_="cardDimensionsOval")
            else "1x1"
        ),
        "ti": (
            soup.find(id="largeCardToken")["src"]
            if soup.find(id="largeCardToken")
            else None
        ),
    }

    return result

def parse_special_object(soup):
    # =====================================================
    # DESCRIPTION PROCESSING
    # =====================================================

    descriptions = [
        el for el in soup.find_all(
            class_="largeCardSpecialPowerDescription"
        )
    ]

    process_special_power_descriptions(
        descriptions
    )

    # =====================================================
    # NAME
    # =====================================================

    name = ""

    name_el = soup.find(
        id="largeCardName"
    )

    if name_el:

        name = name_el.get_text(
            strip=True
        )

    # =====================================================
    # DESCRIPTION
    # =====================================================

    description = ""

    if descriptions:

        description = descriptions[0].get_text(
            " ",
            strip=True
        )

    # =====================================================
    # COST
    # =====================================================

    cost = 0

    cost_el = soup.find(
        class_="largeCardObjectPointValues"
    )

    if cost_el:

        match = re.search(
            r"\d+",
            cost_el.get_text()
        )

        if match:
            cost = int(match.group())

    # =====================================================
    # IMAGE URL
    # =====================================================

    image_url = None

    image_el = soup.find(
        id="largeCardTokenImg"
    )

    if (
        image_el
        and image_el.has_attr("src")
    ):

        image_url = image_el["src"]

    # =====================================================
    # RESULT
    # =====================================================

    result = {

        "tp": "SPECIAL_OBJECT",

        "n": name,

        "d": description,

        "c": cost,

        "iu": image_url
    }

    return result

def parse_one_shot(soup):
    # =====================================================
    # DESCRIPTION PROCESSING
    # =====================================================

    descriptions = [
        el for el in soup.find_all(
            class_="largeCardSpecialPowerDescription"
        )
    ]

    process_special_power_descriptions(
        descriptions
    )

    # =====================================================
    # NAME
    # =====================================================

    name = ""

    name_el = soup.find(
        id="largeCardName"
    )

    if name_el:

        name = name_el.get_text(
            strip=True
        )

    # =====================================================
    # DESCRIPTION
    # =====================================================

    description = ""

    if descriptions:

        description = descriptions[0].get_text(
            " ",
            strip=True
        )

    # =====================================================
    # ART URL
    # =====================================================

    art_url = None

    art_el = soup.find(
        id="largeCardOneShot"
    )

    if (
        art_el
        and art_el.has_attr("src")
    ):

        art_url = art_el["src"]

    # =====================================================
    # POINTS
    # =====================================================

    points = 0

    points_el = soup.find(
        class_="largeCardObjectPointValues"
    )

    if points_el:

        match = re.search(
            r"\d+",
            points_el.get_text()
        )

        if match:
            points = int(match.group())

    # =====================================================
    # RESULT
    # =====================================================

    result = {

        "tp": "ONE_SHOT",

        "n": name,

        "d": description,

        "au": art_url,

        "p": points
    }

    return result
 
def parse_terrain(soup):
    # =====================================================
    # NAME
    # =====================================================

    name = soup.find(
        id="largeCardName"
    ).get_text(strip=True)

    # =====================================================
    # TERRAIN TYPE
    # ELEVATED TERRAIN -> ELEVATED
    # =====================================================

    type_info = soup.find(
        id=lambda value: value and "largeCardTypeInfo" in value
    )

    terrain_type = ""

    if type_info:

        terrain_type = (
            type_info
            .get_text(" ", strip=True)
            .upper()
            .replace(" TERRAIN", "")
            .strip()
        )

    # =====================================================
    # IMAGE URL
    # =====================================================

    image_el = soup.find(
        id="largeCardTerrainMarker"
    )

    image_url = (
        image_el["src"]
        if image_el and image_el.has_attr("src")
        else None
    )

    # =====================================================
    # DIAL VALUES
    # =====================================================

    tds = soup.select(
        "#largeCardTerrainMarkerDial td"
    )

    # defaults
    range_value = 0
    giants_reach = 0

    thrown_damage = 0
    added_damage = ""

    damage_to_destroy = 0

    # -----------------------------------------------------
    # FIRST TD
    # "4 / 2"
    # -----------------------------------------------------

    if len(tds) >= 1:

        text = tds[0].get_text(
            " ",
            strip=True
        )

        parts = [
            p.strip()
            for p in text.split("/")
        ]

        if len(parts) >= 2:

            range_value = safe_int(parts[0])
            giants_reach = safe_int(parts[1])

    # -----------------------------------------------------
    # SECOND TD
    # "3 / +2"
    # -----------------------------------------------------

    if len(tds) >= 2:

        text = tds[1].get_text(
            " ",
            strip=True
        )

        parts = [
            p.strip()
            for p in text.split("/")
        ]

        if len(parts) >= 2:

            thrown_damage = safe_int(parts[0])
            added_damage = parts[1]

    # -----------------------------------------------------
    # THIRD TD
    # "3"
    # -----------------------------------------------------

    if len(tds) >= 3:

        damage_to_destroy = int(
            tds[2].get_text(
                " ",
                strip=True
            )
        )

    # =====================================================
    # RESULT
    # =====================================================

    result = {
        "tp": "TERRAIN",

        "n": name,

        "tt": terrain_type,

        "iu": image_url,

        "r": range_value,

        "gr": giants_reach,

        "td": thrown_damage,

        "ad": added_damage,

        "dd": damage_to_destroy
    }

    return result

def parse_terrain_marker(soup):

    # =====================================================
    # DESCRIPTION PROCESSING
    # =====================================================

    descriptions = [
        el for el in soup.find_all(
            class_="largeCardSpecialPowerDescription"
        )
    ]

    process_special_power_descriptions(
        descriptions
    )

    # =====================================================
    # NAME
    # =====================================================

    name = ""

    name_el = soup.find(
        id="largeCardName"
    )

    if name_el:

        name = name_el.get_text(
            strip=True
        )

    # =====================================================
    # TYPE
    # BLOCKING TERRAIN -> BLOCKING
    # =====================================================

    terrain_type = ""

    type_el = soup.find(
        id=lambda value: value and "largeCardTypeInfo" in value
    )

    if type_el:

        terrain_type = (
            type_el
            .get_text(" ", strip=True)
            .upper()
            .replace(" TERRAIN", "")
            .strip()
        )

    # =====================================================
    # DESCRIPTION
    # =====================================================

    description = ""

    if descriptions:

        description = descriptions[0].get_text(
            " ",
            strip=True
        )

    # =====================================================
    # IMAGE
    # =====================================================

    image_url = None

    image_el = soup.find(
        id="largeCardTerrainMarker"
    )

    if (
        image_el
        and image_el.has_attr("src")
    ):

        image_url = image_el["src"]

    # =====================================================
    # COST
    # =====================================================

    cost = 0

    cost_el = soup.find(
        class_="largeCardObjectPointValues"
    )

    if cost_el:

        match = re.search(
            r"\d+",
            cost_el.get_text()
        )

        if match:
            cost = int(match.group())

    # =====================================================
    # RESULT
    # =====================================================

    result = {

        "tp": "TERRAIN_MARKER",

        "n": name,

        "tt": terrain_type,

        "d": description,

        "iu": image_url,

        "c": cost
    }

    return result

def parse_map(soup):
    map_name = soup.find(
        id="largeCardName"
    ).get_text(strip=True)

    type_info = soup.find(
        id=lambda value: value and "largeCardTypeInfo" in value
    )

    map_type = None

    if type_info:

        text = type_info.get_text(
            " ",
            strip=True
        ).upper()

        match = re.search(r"\((.*?)\)", text)

        if match:
            map_type = match.group(1)

    result = {
        "tp": "MAP",
        "mn": map_name,
        "mt": map_type
    }

    return result

def parse_bystander(soup):

    # =====================================================
    # SPECIAL POWER DESCRIPTION PROCESSING
    # SAME AS FIGURES
    # =====================================================

    special_descriptions = [
        el for el in soup.find_all(
            class_="largeCardSpecialPowerDescription"
        )
    ]

    # KO
    for el in special_descriptions:
        for ko in el.find_all(class_="specialPowerEmbedKO"):
            ko.parent.replace_with(" KO'd ")

    # DICE
    for el in special_descriptions:

        for die in el.find_all(
            class_="specialPowerEmbedDie"
        ):

            icon = die.find("i")

            if icon:

                classes = icon.get("class", [])

                for cls in classes:

                    match = re.search(
                        r"d6-(\d)",
                        cls
                    )

                    if match:

                        die.parent.replace_with(
                            f" {match.group(1)} "
                        )

                        break

    # TARGETS
    for el in special_descriptions:

        children = list(el.children)

        bolt_groups = []

        for child in children:

            if isinstance(child, Tag):

                img = child.find("img")

                if (
                    img
                    and "bolt.svg" in img.get("src", "")
                ):

                    bolt_groups.append(child)

                else:

                    if bolt_groups:

                        count = len(bolt_groups)

                        bolt_groups[0].replace_with(
                            f" {count} targets "
                        )

                        for group in bolt_groups[1:]:
                            group.decompose()

                        bolt_groups = []

        if bolt_groups:

            count = len(bolt_groups)

            bolt_groups[0].replace_with(
                f" {count} targets "
            )

            for group in bolt_groups[1:]:
                group.decompose()

    # GENERIC EMBEDS
    for el in special_descriptions:

        for embed in el.find_all(
            class_="specialPowerEmbed"
        ):

            img = embed.find("img")

            title = embed.get(
                "data-mdb-original-title"
            )

            if img and title:

                bs = BeautifulSoup(
                    title,
                    "html.parser"
                )

                name = bs.b.get_text(
                    strip=True
                )

                embed.parent.replace_with(
                    f" {name} "
                )

    # =====================================================
    # NAME
    # =====================================================

    name = soup.find(
        id="largeCardName"
    ).get_text(strip=True)

    # =====================================================
    # RANGE
    # =====================================================

    range_value = int(
        soup.find(
            id="smallCardRange"
        ).get_text(strip=True)
    )

    # =====================================================
    # TARGETS
    # =====================================================

    targets = len(
        soup.find_all(class_="smallCardBolt")
    )

    # =====================================================
    # IMAGE URL
    # =====================================================

    img_url = None

    img_el = soup.find(
        id="smallCardBystanderTokenImg"
    )

    if (
        img_el
        and img_el.has_attr("src")
    ):

        img_url = img_el["src"]

    # =====================================================
    # COMBAT TYPES
    # =====================================================

    def get_symbol(id_name):

        el = soup.find(id=id_name)

        if not el:
            return None

        img = el.find("img")

        if (
            not img
            or not img.has_attr("src")
        ):
            return None

        return (
            img["src"]
            .split("/")[-1]
            .replace(".svg", "")
        )

    movement_type = get_symbol(
        "smallCardCombatSymbolSpeed"
    )

    attack_type = get_symbol(
        "smallCardCombatSymbolAttack"
    )

    defense_type = get_symbol(
        "smallCardCombatSymbolDefense"
    )

    damage_type = get_symbol(
        "smallCardCombatSymbolDamage"
    )

    # =====================================================
    # TEAM ABILITY
    # =====================================================

    team_ability = None

    team_el = soup.find(
        class_="smallCardTeamAbility"
    )

    if team_el:

        aria = team_el.get("aria-label")

        if aria:

            bs = BeautifulSoup(
                aria,
                "html.parser"
            )

            b = bs.find("b")

            if b:
                team_ability = b.get_text(
                    strip=True
                )

    # =====================================================
    # DIAL ENTRIES
    # =====================================================

    entries = soup.find_all(
        class_="smallCardDialEntry"
    )

    movement_value = 0
    movement_ability = "NONE"

    attack_value = 0
    attack_ability = "NONE"

    defense_value = 0
    defense_ability = "NONE"

    damage_value = 0
    damage_ability = "NONE"

    def parse_entry(entry):

        value = int(
            entry.find("div")
            .get_text(strip=True)
        )

        ability = "NONE"

        title = entry.get(
            "data-mdb-original-title"
        )

        if title:

            bs = BeautifulSoup(
                title,
                "html.parser"
            )

            b = bs.find("b")

            if b:
                ability = b.get_text(
                    strip=True
                )

        return value, ability

    if len(entries) >= 1:
        movement_value, movement_ability = parse_entry(entries[0])

    if len(entries) >= 2:
        attack_value, attack_ability = parse_entry(entries[1])

    if len(entries) >= 3:
        defense_value, defense_ability = parse_entry(entries[2])

    if len(entries) >= 4:
        damage_value, damage_ability = parse_entry(entries[3])

    # =====================================================
    # SPECIAL POWERS
    # =====================================================

    special_power_types = [
        el.find_all("img")[1]["src"]
        .split("/")[-1]
        .replace(".svg", "")

        for el in soup.find_all(
            class_="specialPowerIcon"
        )
    ]

    special_power_names = [
        el.get_text(strip=True)

        for el in soup.find_all(
            class_="largeCardSpecialPowerName"
        )
    ]

    special_power_descriptions = [
        el.get_text(" ", strip=True)

        for el in special_descriptions
    ]

    # =====================================================
    # RESULT
    # =====================================================

    result = {

        "tp": "BYSTANDER",

        "n": name,

        "r": range_value,

        "t": targets,

        "iu": img_url,

        "mt": movement_type,

        "at": attack_type,

        "dt": defense_type,

        "dmt": damage_type,

        "ta": team_ability,

        "mv": movement_value,
        "ma": movement_ability,

        "av": attack_value,
        "aa": attack_ability,

        "dv": defense_value,
        "da": defense_ability,

        "dmv": damage_value,
        "dma": damage_ability,

        "spt": special_power_types,

        "spn": special_power_names,

        "spd": special_power_descriptions
    }

    return result

def parse_equipment(soup):

    # =====================================================
    # DESCRIPTION EMBED PROCESSING
    # SAME LOGIC AS SPECIAL POWERS
    # =====================================================

    descriptions = [
        el for el in soup.find_all(
            class_="largeCardSpecialPowerDescription"
        )
    ]

    # KO
    for el in descriptions:
        for ko in el.find_all(class_="specialPowerEmbedKO"):
            ko.parent.replace_with(" KO'd ")

    # DICE
    for el in descriptions:
        for die in el.find_all(class_="specialPowerEmbedDie"):

            icon = die.find("i")

            if icon:

                classes = icon.get("class", [])

                for cls in classes:

                    match = re.search(
                        r"d6-(\d)",
                        cls
                    )

                    if match:

                        die.parent.replace_with(
                            f" {match.group(1)} "
                        )

                        break

    # SET
    for el in descriptions:

        for embed in el.find_all(
            class_="specialPowerEmbed"
        ):

            label = embed.get("aria-label")

            img = embed.find("img")

            if (
                label
                and img
                and "/images/set/" in img.get("src", "")
            ):

                embed.parent.replace_with(
                    f" {label} Set "
                )

    # TARGETS
    for el in descriptions:

        children = list(el.children)

        bolt_groups = []

        for child in children:

            if isinstance(child, Tag):

                img = child.find("img")

                if (
                    img
                    and "bolt.svg" in img.get("src", "")
                ):

                    bolt_groups.append(child)

                else:

                    if bolt_groups:

                        count = len(bolt_groups)

                        bolt_groups[0].replace_with(
                            f" {count} targets "
                        )

                        for group in bolt_groups[1:]:
                            group.decompose()

                        bolt_groups = []

        if bolt_groups:

            count = len(bolt_groups)

            bolt_groups[0].replace_with(
                f" {count} targets "
            )

            for group in bolt_groups[1:]:
                group.decompose()

    # TEAM ABILITIES
    for el in descriptions:

        for embed in el.find_all(
            class_="specialPowerEmbed"
        ):

            img = embed.find("img")

            label = embed.get("aria-label")

            if (
                img
                and label
                and "/images/ta/" in img.get("src", "")
            ):

                bs = BeautifulSoup(
                    label,
                    "html.parser"
                )

                name = bs.b.get_text(strip=True)

                embed.parent.replace_with(
                    f" {name} "
                )

    # IMPROVED ABILITIES
    for el in descriptions:

        for group in el.find_all(
            class_="specialPowerEmbedGroup"
        ):

            embeds = group.find_all(
                class_="specialPowerEmbed"
            )

            for embed in embeds:

                img = embed.find("img")

                title = embed.get(
                    "data-mdb-original-title"
                )

                if (
                    img
                    and title
                    and "/images/imp/" in img.get("src", "")
                ):

                    bs = BeautifulSoup(
                        title,
                        "html.parser"
                    )

                    name = bs.b.get_text(
                        strip=True
                    )

                    description = (
                        bs.get_text(
                            " ",
                            strip=True
                        )
                        .replace(name, "", 1)
                        .lstrip(": ")
                        .strip()
                    )

                    group.replace_with(
                        f" {name}: {description} "
                    )

                    break

    # GENERIC EMBEDS
    for el in descriptions:

        for embed in el.find_all(
            class_="specialPowerEmbed"
        ):

            img = embed.find("img")

            title = embed.get(
                "data-mdb-original-title"
            )

            if img and title:

                bs = BeautifulSoup(
                    title,
                    "html.parser"
                )

                name = bs.b.get_text(
                    strip=True
                )

                embed.parent.replace_with(
                    f" {name} "
                )

    # =====================================================
    # NAME
    # =====================================================

    name = soup.find(
        id="largeCardName"
    ).get_text(strip=True)

    # =====================================================
    # DEFAULTS
    # =====================================================

    special_power_title = None

    qualifying_name = None

    qualifying_keywords = None

    equip = None

    unequip = None

    # =====================================================
    # KEYPHRASES
    # =====================================================

    keyphrases = soup.find_all(
        class_="largeCardKeyphrase"
    )

    for el in keyphrases:

        text = el.get_text(
            " ",
            strip=True
        )

        upper = text.upper()

        # SPECIAL POWER TITLE
        if (
            special_power_title is None
            and "QUALIFYING" not in upper
            and "EQUIP:" not in upper
            and "UNEQUIP:" not in upper
        ):

            special_power_title = text

        # QUALIFYING NAME
        if "QUALIFYING NAME:" in upper:

            qualifying_name = (
                text
                .replace(
                    "QUALIFYING NAME:",
                    ""
                )
                .strip()
            )

        # QUALIFYING KEYWORDS
        if "QUALIFYING KEYWORDS:" in upper:

            qualifying_keywords = (
                text
                .replace(
                    "QUALIFYING KEYWORDS:",
                    ""
                )
                .strip()
            )

        # EQUIP
        if "EQUIP:" in upper:

            equip = (
                text
                .replace("EQUIP:", "")
                .strip()
            )

        # UNEQUIP
        if "UNEQUIP:" in upper:

            unequip = (
                text
                .replace("UNEQUIP:", "")
                .strip()
            )

    # =====================================================
    # DESCRIPTION
    # =====================================================

    description = None

    if descriptions:

        description = descriptions[0].get_text(
            " ",
            strip=True
        )

    # =====================================================
    # IMAGE
    # =====================================================

    image = None

    image_el = soup.find(
        id="largeCardTokenImg"
    )

    if (
        image_el
        and image_el.has_attr("src")
    ):

        image = image_el["src"]

    # =====================================================
    # COST
    # =====================================================

    cost = 0

    cost_el = soup.find(
        class_="largeCardObjectPointValues"
    )

    if cost_el:

        match = re.search(
            r"\d+",
            cost_el.get_text()
        )

        if match:
            cost = int(match.group())

    # =====================================================
    # RESULT
    # =====================================================

    result = {
        "tp": "EQUIPMENT",

        "n": name,

        "spt": special_power_title,

        "qn": qualifying_name,

        "qk": qualifying_keywords,

        "eq": equip,

        "ue": unequip,

        "d": description,

        "i": image,

        "c": cost
    }

    return result

def normalize_card_type(raw_type, soup):

    if not raw_type:
        return "FIGURE"
    
    # =====================================================
    # TERRAIN MARKER
    # =====================================================

    if (
        "TERRAIN" in raw_type
        and soup.find(id="largeCardTerrainMarkerIcon")
    ):
        return "TERRAIN_MARKER"

    # =====================================================
    # NORMAL TYPES
    # =====================================================


    if "BYSTANDER" in raw_type:
        return "BYSTANDER"

    if "EQUIPMENT" in raw_type:
        return "EQUIPMENT"

    if "MAP" in raw_type:
        return "MAP"

    if "TERRAIN" in raw_type:
        return "TERRAIN"

    if "ONE-SHOT" in raw_type:
        return "ONE_SHOT"

    if "SPECIAL OBJECT" in raw_type:
        return "SPECIAL_OBJECT"

    if "POSSESSOR" in raw_type:
        return "POSSESSOR"

    return "FIGURE" 

def extract_key(filename):
    """
    Examples:
    hcunits.net_units_wkm23M23-002bt_.html -> 002bt
    hcunits.net_units_av60014_.html -> av60014
    """

    # remove .html
    name = filename.replace(".html", "")

    # remove trailing underscore
    name = name.rstrip("_")

    # split on underscores and take last part
    return name.split("_")[-1]

def process_special_power_descriptions(descriptions):

    # KO
    for el in descriptions:
        for ko in el.find_all(class_="specialPowerEmbedKO"):
            ko.parent.replace_with(" KO'd ")

    # DICE
    for el in descriptions:

        for die in el.find_all(class_="specialPowerEmbedDie"):

            icon = die.find("i")

            if icon:

                classes = icon.get("class", [])

                for cls in classes:

                    match = re.search(
                        r"d6-(\d)",
                        cls
                    )

                    if match:

                        die.parent.replace_with(
                            f" {match.group(1)} "
                        )

                        break

    # SET
    for el in descriptions:

        for embed in el.find_all(
            class_="specialPowerEmbed"
        ):

            label = embed.get("aria-label")

            img = embed.find("img")

            if (
                label
                and img
                and "/images/set/" in img.get("src", "")
            ):

                embed.parent.replace_with(
                    f" {label} Set "
                )

    # TARGETS
    for el in descriptions:

        children = list(el.children)

        bolt_groups = []

        for child in children:

            if isinstance(child, Tag):

                img = child.find("img")

                if (
                    img
                    and "bolt.svg" in img.get("src", "")
                ):

                    bolt_groups.append(child)

                else:

                    if bolt_groups:

                        count = len(bolt_groups)

                        bolt_groups[0].replace_with(
                            f" {count} targets "
                        )

                        for group in bolt_groups[1:]:
                            group.decompose()

                        bolt_groups = []

        if bolt_groups:

            count = len(bolt_groups)

            bolt_groups[0].replace_with(
                f" {count} targets "
            )

            for group in bolt_groups[1:]:
                group.decompose()

    # TEAM ABILITIES
    for el in descriptions:

        for embed in el.find_all(
            class_="specialPowerEmbed"
        ):

            img = embed.find("img")

            label = embed.get("aria-label")

            if (
                img
                and label
                and "/images/ta/" in img.get("src", "")
            ):

                bs = BeautifulSoup(
                    label,
                    "html.parser"
                )

                name = bs.b.get_text(
                    strip=True
                )

                embed.parent.replace_with(
                    f" {name} "
                )

    # IMPROVED ABILITIES
    for el in descriptions:

        for group in el.find_all(
            class_="specialPowerEmbedGroup"
        ):

            embeds = group.find_all(
                class_="specialPowerEmbed"
            )

            for embed in embeds:

                img = embed.find("img")

                title = embed.get(
                    "data-mdb-original-title"
                )

                if (
                    img
                    and title
                    and "/images/imp/" in img.get("src", "")
                ):

                    bs = BeautifulSoup(
                        title,
                        "html.parser"
                    )

                    name = bs.b.get_text(
                        strip=True
                    )

                    description = (
                        bs.get_text(
                            " ",
                            strip=True
                        )
                        .replace(name, "", 1)
                        .lstrip(": ")
                        .strip()
                    )

                    group.replace_with(
                        f" {name}: {description} "
                    )

                    break

    # GENERIC EMBEDS
    for el in descriptions:

        for embed in el.find_all(
            class_="specialPowerEmbed"
        ):

            img = embed.find("img")

            title = embed.get(
                "data-mdb-original-title"
            )

            if img and title:

                bs = BeautifulSoup(
                    title,
                    "html.parser"
                )

                name = bs.b.get_text(
                    strip=True
                )

                embed.parent.replace_with(
                    f" {name} "
                )

def safe_int(value, default=0):

    value = str(value).strip()

    if value == "-":
        return default

    try:
        return int(value)
    except:
        return default
    
# walk folders
for root, dirs, files in os.walk(OUTPUT_DIR):

    for file in files:

        if file.endswith(".html"):

            html_path = os.path.join(root, file)

            try:
                key = extract_key(file)

                print(f"Processing {file} -> {key}")

                result = parse_html(html_path)

                all_units[key] = result

            except Exception as e:
                print(f"FAILED: {file}")
                print(e)

# # save final json
with open(RESULT_FILE, "w", encoding="utf-8") as f:
    json.dump(all_units, f, indent=4, ensure_ascii=False)
# with open(RESULT_FILE, "w", encoding="utf-8") as f:
#     json.dump(
#         all_units,
#         f,
#         ensure_ascii=False,
#         separators=(",", ":")
#     )

print(f"Saved {len(all_units)} units to {RESULT_FILE}")