# Configuration file for the Sphinx documentation builder.

# -- Project information
import os
import subprocess
import logging
from sphinx.application import Sphinx


# Dashboard Generation
import os
import subprocess
import logging
from sphinx.application import Sphinx
import subprocess


project = "MEG Pipeline"
copyright = "2024, Hadi Zaatiti"
author = "Hadi Zaatiti hadi.zaatiti@nyu.edu"

release = "0.1"
version = "0.1.0"

# -- General configuration

extensions = [
    "sphinx.ext.duration",
    "sphinx.ext.doctest",
    "sphinx.ext.autodoc",
    "sphinx.ext.autosummary",
    "sphinx.ext.intersphinx",
    "nbsphinx",
    "sphinx_gallery.load_style",
    "sphinx.ext.mathjax",
]
intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "sphinx": ("https://www.sphinx-doc.org/en/master/", None),
}
intersphinx_disabled_domains = ["std"]

templates_path = ["_templates"]

# -- Options for HTML output

html_theme = "sphinx_rtd_theme"
html_logo = "graphic/NYU_Logo.png"
html_theme_options = {
    "logo_only": False,
    "display_version": True,
    "prev_next_buttons_location": "bottom",
    "style_external_links": False,
    "vcs_pageview_mode": "",
    "style_nav_header_background": "#561A70",
    # Toc options
    "collapse_navigation": True,
    "sticky_navigation": True,
    "navigation_depth": 4,
    "includehidden": True,
    "titles_only": False,
}

suppress_warnings = [
    "epub.unknown_project_files"
]  # This allows us to avoid the warning caused by html files in _static directory (regarding mime types)

html_css_files = [
    "custom.css",
]

html_static_path = ["_static"]
# -- Options for EPUB output
epub_show_urls = "footnote"



def run_generate_system_status_dashboards_script(app: Sphinx):
    """Run the dashboard generation script."""
    logger = logging.getLogger(__name__)
    script_path = os.path.join(
        app.confdir, "9-dashboard", "dashboard-generating-scripts", "generate_system_status_dashboards.py"
    )

    if os.path.exists(script_path):
        logger.info(f"Found generate_system_status_dashboards.py at {script_path}, running it now.")
        result = subprocess.run(["python", script_path], capture_output=True, text=True)
        if result.returncode == 0:
            logger.info("generate_system_status_dashboards.py ran successfully.")

        else:
            logger.error(f"generate_system_status_dashboards.py failed with return code {result.returncode}")

        logger.info(result.stdout)
        logger.error(result.stderr)

    else:
        logger.error(f"The script {script_path} does not exist.")

def run_box_script(app: Sphinx):
    """Run the dashboard generation script."""
    logger = logging.getLogger(__name__)
    script_path = os.path.join(
        app.confdir, "9-dashboard", "dashboard-generating-scripts", "box_script.py"
    )

    if os.path.exists(script_path):
        logger.info(f"Found box_script.py at {script_path}, running it now.")
        result = subprocess.run(["python", script_path], capture_output=True, text=True)
        if result.returncode == 0:
            logger.info("box_script.py ran successfully.")

        else:
            logger.error(f"box_script.py failed with return code {result.returncode}")

        logger.info(result.stdout)
        logger.error(result.stderr)

    else:
        logger.error(f"The script {script_path} does not exist.")




def run_csv_conversion(app):
    logger = logging.getLogger(__name__)
    script_path = os.path.join(
        app.confdir,
        "9-dashboard",
        "dashboard-generating-scripts",
        "convert_csv_to_rst.py",
    )

    if os.path.exists(script_path):
        logger.info(f"Found convert_csv_to_rst.py at {script_path}, running it now.")

        result = subprocess.run(
            ["python", script_path], check=True, capture_output=True, text=True
        )

        if result.returncode == 0:
            logger.info("convert_csv_to_rst.py ran successfully.")
        else:
            logger.error(
                f"convert_csv_to_rst.py failed with return code {result.returncode}"
            )
            logger.error(result.stdout)
            logger.error(result.stderr)
            raise RuntimeError(
                f"CSV to RST conversion script failed with exit code {result.returncode}"
            )
    else:
        logger.error(f"The script {script_path} does not exist.")


def run_proccessing_files(app):
    logger = logging.getLogger(__name__)
    script_path = os.path.join(
        app.confdir,
        "9-dashboard",
        "dashboard-generating-scripts",
        "proccessing_con_files_for_table.py",
    )

    if os.path.exists(script_path):
        logger.info(f"Found {script_path}, running it now.")

        try:
            result = subprocess.run(
                ["python", script_path], check=True, capture_output=True, text=True
            )

            if result.returncode == 0:
                logger.info(f"{script_path} ran successfully.")
            else:
                logger.error(
                    f"{script_path} failed with return code {result.returncode}"
                )
                raise RuntimeError(f"Script failed with exit code {result.returncode}")

            # Log both stdout and stderr
            if result.stdout:
                logger.info(f"Script output: {result.stdout}")
            if result.stderr:
                logger.error(f"Script errors: {result.stderr}")

        except subprocess.CalledProcessError as e:
            logger.error(f"Error running {script_path}: {e}")
            logger.error(f"Stdout: {e.stdout}")
            logger.error(f"Stderr: {e.stderr}")
            raise RuntimeError(
                f"Error while running script: {script_path}. Exit code: {e.returncode}"
            ) from e

        except Exception as e:
            logger.exception(f"Unexpected error while running {script_path}: {e}")
            raise

    else:
        logger.error(f"The script {script_path} does not exist.")
        raise FileNotFoundError(f"Script {script_path} not found.")


def setup(app: Sphinx):
    logging.basicConfig(level=logging.INFO)
    app.connect("builder-inited", run_generate_system_status_dashboards_script)
    app.connect("builder-inited", run_box_script)
    app.connect("builder-inited", run_proccessing_files)
    app.connect("builder-inited", run_csv_conversion)
    # app.add_css_file('custom.css')
