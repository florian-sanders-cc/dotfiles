#! /usr/bin/env node
"use strict";

const readline = require("node:readline");

const fs = require("node:fs/promises");
const { spawnSync } = require("node:child_process");

const CONFIG_PATH = `${process.env.HOME}/.config/clever-cloud`;

async function prompt() {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });
    rl.question(`Select the profile you want to switch to:`, (choice) => {
      rl.close();
      resolve(choice);
    });
  });
}

(async function () {
  const currentTokens = await fs
    .readFile(CONFIG_PATH + "/clever-tools.json", "utf8")
    .then((json) => {
      return JSON.parse(json);
    })
    .catch(() => null);

  const result = spawnSync("clever", [
    "curl",
    "https://api.clever-cloud.com/v2/self",
  ]);
  const selfJson = result.stdout.toString();
  const self = JSON.parse(selfJson);

  const currentProfile =
    self.type !== "error"
      ? {
          name: self.name,
          email: self.email,
          id: self.id,
          ...currentTokens,
        }
      : null;

  const profiles = await fs
    .readFile(CONFIG_PATH + "/profiles.json", "utf8")
    .then((json) => {
      return JSON.parse(json);
    })
    .catch(() => []);

  if (
    currentProfile != null &&
    profiles.find(({ id }) => id === currentProfile.id) == null
  ) {
    profiles.push(currentProfile);
  }

  for (const p of profiles) {
    p.current = p.id === currentProfile?.id;
  }

  await fs.writeFile(
    CONFIG_PATH + "/profiles.json",
    JSON.stringify(profiles, null, 2),
  );

  const choices = profiles
    // .filter(({ current }) => !current)
    .map(({ name, email, id }) => ({ name, email, id }));

  if (choices.length === 0) {
    console.log("No profiles to switch to :-(");
  } else {
    if (currentProfile != null) {
      console.log(`Current profile:`);
      console.log("  " + currentProfile.email);
      console.log("  " + currentProfile.id);
      console.log("");
    }

    console.table(choices);
    console.log("");
    const choiceIndex = await prompt();
    const profileToSwitch = profiles[choiceIndex];
    if (profileToSwitch == null) {
      console.log("Invalid choice :-(");
    } else {
      const tokens = {
        token: profileToSwitch.token,
        secret: profileToSwitch.secret,
      };
      await fs.writeFile(
        CONFIG_PATH + "/clever-tools.json",
        JSON.stringify(tokens, null, 2),
      );
      console.log(`Current profile is now:`);
      console.log("  " + profileToSwitch.email);
      console.log("  " + profileToSwitch.id);
    }
  }
})();
