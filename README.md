# Halara Resource Pack

Halara Network's server resource pack for Minecraft Java Edition 26.2.

## Compatibility

- Resource-pack format: `88.0`
- Token item models use the modern `assets/minecraft/items` definition format.
- Halara plugins set the first `minecraft:custom_model_data` float to select a
  model. Legacy Halara token values remain compatible.

## Validate

Run the repository validator before publishing:

```sh
./scripts/validate-pack.sh
```

It parses every JSON file and verifies the pack version plus local model,
texture, and bitmap-font references.
