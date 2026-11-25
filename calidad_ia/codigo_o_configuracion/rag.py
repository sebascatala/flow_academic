
import re
import json
import unicodedata

from pathlib import Path
from datetime import datetime, timezone


BASE_DIR = Path(__file__).resolve().parent.parent
FUENTES_DIR = BASE_DIR / "fuentes_rag"
EVIDENCIAS_DIR = BASE_DIR / "evidencias"

PALABRAS_VACIAS = {
    "a", "al", "de", "del", "el", "la", "las", "los",
    "un", "una", "unos", "unas", "en", "y", "o",
    "que", "se", "es", "para", "por", "con", "su",
    "sus", "como", "cual", "cuales", "cada", "sobre",
    "deben", "debe", "tiene", "son", "utiliza"
}


def normalizar(texto):
    """Normaliza el texto para facilitar la búsqueda."""

    texto = unicodedata.normalize("NFD", texto.lower())

    texto = "".join(
        caracter for caracter in texto
        if unicodedata.category(caracter) != "Mn"
    )

    palabras = re.findall(r"[a-z0-9]+", texto)

    return {
        palabra for palabra in palabras
        if palabra not in PALABRAS_VACIAS
    }


def cargar_fragmentos():
    """Lee y divide las fuentes documentales."""

    fragmentos = []

    for archivo in sorted(FUENTES_DIR.glob("*.txt")):

        contenido = archivo.read_text(
            encoding="utf-8-sig"
        )

        partes = re.split(r"\n\s*\n", contenido.strip())

        for numero, parte in enumerate(partes[1:], start=1):

            if parte.strip():
                fragmentos.append({
                    "fuente": archivo.stem,
                    "fragmento_id": f"{archivo.stem}-F{numero:02d}",
                    "texto": parte.strip()
                })

    return fragmentos


def recuperar(consulta, limite=5):
    """Recupera los fragmentos con mayor coincidencia."""

    terminos = normalizar(consulta)

    if not terminos:
        return []

    resultados = []

    for fragmento in cargar_fragmentos():

        palabras = normalizar(fragmento["texto"])
        coincidencias = terminos.intersection(palabras)

        if not coincidencias:
            continue

        puntaje = len(coincidencias) / len(terminos)

        resultados.append({
            **fragmento,
            "puntaje": round(puntaje, 4),
            "coincidencias": sorted(coincidencias)
        })

    resultados.sort(
        key=lambda resultado: resultado["puntaje"],
        reverse=True
    )

    return resultados[:limite]


def registrar_consulta(consulta, resultados):
    """Registra la recuperación documental realizada."""

    EVIDENCIAS_DIR.mkdir(exist_ok=True)

    registro = {
        "fecha": datetime.now(timezone.utc).isoformat(),
        "consulta": consulta,
        "fragmentos_recuperados": resultados
    }

    archivo = EVIDENCIAS_DIR / "consultas_rag.jsonl"

    with archivo.open("a", encoding="utf-8") as salida:
        salida.write(
            json.dumps(registro, ensure_ascii=False) + "\n"
        )


if __name__ == "__main__":

    consulta = input("Ingrese una consulta: ")

    resultados = recuperar(consulta)

    registrar_consulta(consulta, resultados)

    if not resultados:
        print("\nNo se encontraron fragmentos relevantes.")

    else:
        print("\nFRAGMENTOS RECUPERADOS\n")

        for resultado in resultados:

            print(f"Fuente: {resultado['fuente']}")
            print(f"ID: {resultado['fragmento_id']}")
            print(f"Puntaje: {resultado['puntaje']}")
            print(f"Texto: {resultado['texto']}")
            print("-" * 50)
