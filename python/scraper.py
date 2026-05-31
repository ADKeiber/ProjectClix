from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

import os
import re
import time


BASE_URL = "https://hcunits.net/units/"
OUTPUT_DIR = "output"


# -----------------------------
# DRIVER
# -----------------------------

options = webdriver.EdgeOptions()
options.add_argument("--start-maximized")

# optional
# options.add_argument("--headless")

driver = webdriver.Edge(options=options)

wait = WebDriverWait(driver, 20)


# -----------------------------
# HELPERS
# -----------------------------

def sanitize_filename(name):
    return re.sub(r'[\\/*?:"<>|]', "_", name)


def save_html(set_name):

    url = driver.current_url

    filename = sanitize_filename(
        url.replace("https://", "")
    ) + ".html"

    set_folder = os.path.join(
        OUTPUT_DIR,
        sanitize_filename(set_name)
    )

    os.makedirs(set_folder, exist_ok=True)

    filepath = os.path.join(set_folder, filename)

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(driver.page_source)

    print(f"Saved: {filepath}")


def wait_for_unit_cards():

    wait.until(
        EC.visibility_of_element_located(
            (By.ID, "unitCards")
        )
    )


def get_set_elements():

    return driver.find_elements(
        By.CSS_SELECTOR,
        '[id*="setListPanelListItem"]'
    )


def get_unit_elements():

    return driver.find_elements(
        By.CSS_SELECTOR,
        '[id*="unitListPanelItem"]'
    )


# -----------------------------
# START
# -----------------------------

print("Opening site...")

driver.get(BASE_URL)

time.sleep(3)

set_index = 1


# -----------------------------
# MAIN LOOP
# -----------------------------

while True:

    set_elements = get_set_elements()

    if set_index > 54 or set_index >= len(set_elements):
        break

    try:

        set_elements = get_set_elements()

        current_set = set_elements[set_index]

        set_name = current_set.text.split("\n")[0].strip()

        print(f"\n===== SET {set_index + 1} =====")
        print(set_name)

        # scroll set into view
        driver.execute_script(
            "arguments[0].scrollIntoView({block: 'center'});",
            current_set
        )

        time.sleep(1)

        # click set
        ActionChains(driver) \
            .move_to_element(current_set) \
            .pause(0.5) \
            .click(current_set) \
            .perform()

        print(driver.current_url)

        time.sleep(2)

        # wait for units to appear
        wait.until(
            lambda d: len(get_unit_elements()) > 0
        )

        unit_index = 0

        # -----------------------------
        # UNIT LOOP
        # -----------------------------

        while True:

            unit_elements = get_unit_elements()

            if unit_index >= len(unit_elements):
                break

            try:

                # IMPORTANT:
                # re-fetch after every navigation
                unit_elements = get_unit_elements()

                current_unit = unit_elements[unit_index]

                unit_name = current_unit.text.strip()

                print(
                    f"[{unit_index + 1}/{len(unit_elements)}] "
                    f"{unit_name}"
                )

                # scroll into view
                driver.execute_script(
                    "arguments[0].scrollIntoView({block: 'center'});",
                    current_unit
                )

                time.sleep(1)

                # wait until visible
                wait.until(
                    EC.visibility_of(current_unit)
                )

                # wait until clickable
                wait.until(
                    EC.element_to_be_clickable(current_unit)
                )

                # click unit
                ActionChains(driver) \
                    .move_to_element(current_unit) \
                    .pause(0.5) \
                    .click(current_unit) \
                    .perform()

                print(driver.current_url)

                # wait for cards
                wait_for_unit_cards()

                time.sleep(1)

                # save html
                save_html(set_name)

                # -----------------------------
                # GO BACK
                # -----------------------------

                # back_button = driver.find_element(
                #     By.ID,
                #     "panelManagerBackButton"
                # )

                # driver.execute_script(
                #     "arguments[0].scrollIntoView({block: 'center'});",
                #     back_button
                # )

                time.sleep(1)

                # IMPORTANT:
                # wait for unit list rebuild
                wait.until(
                    lambda d: len(get_unit_elements()) > 0
                )

                time.sleep(2)

                unit_index += 1

            except Exception as e:

                print(
                    f"ERROR UNIT {unit_index}: {e}"
                )

                try:

                    # back_button = driver.find_element(
                    #     By.ID,
                    #     "panelManagerBackButton"
                    # )

                    # ActionChains(driver) \
                    #     .move_to_element(back_button) \
                    #     .pause(0.5) \
                    #     .click(back_button) \
                    #     .perform()

                    wait.until(
                        lambda d: len(get_unit_elements()) > 0
                    )

                    time.sleep(2)

                except:
                    pass

                unit_index += 1

        # -----------------------------
        # BACK TO SETS
        # -----------------------------

        back_button = driver.find_element(
            By.ID,
            "panelManagerBackButton"
        )

        driver.execute_script(
            "arguments[0].scrollIntoView({block: 'center'});",
            back_button
        )

        time.sleep(1)

        ActionChains(driver) \
            .move_to_element(back_button) \
            .pause(0.5) \
            .click(back_button) \
            .perform()

        time.sleep(2)

        set_index += 1

    except Exception as e:

        print(
            f"ERROR SET {set_index}: {e}"
        )

        # try:

        #     # back_button = driver.find_element(
        #     #     By.ID,
        #     #     "panelManagerBackButton"
        #     # )

        #     # ActionChains(driver) \
        #     #     .move_to_element(back_button) \
        #     #     .pause(0.5) \
        #     #     .click(back_button) \
        #     #     .perform()

        #     # time.sleep(2)

        # except:
        #     pass

        set_index += 1


print("\nDONE")

driver.quit()