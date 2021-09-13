#! /usr/bin/env node

const curry = require('lodash.curry');
const flip = require('lodash.flip');

const groupBy = curry(flip(require('lodash.groupby')), 2);

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const markdownRoot = process.env.npm_package_config_markdownRoot;

execAndSplitOutput = (command, separator) => execSync(command).toString().split(separator).filter(x => x);

const getMarkdownFiles = (root) => execAndSplitOutput(`find ${root} -name \\*.md`, '\n');

const groupByDirectory = groupBy(file => {
    const dirName = path.dirname(file);
    return dirName.substring(markdownRoot.length + 1);
});

const files = getMarkdownFiles(markdownRoot);
const fileGroups = groupByDirectory(files);

const renderGroup = (group) => [`## ${group}`, ...fileGroups[group].map(renderEntry)].join('\n');
const renderEntry = (file) => `* [${getTitle(file)}](${file}) - last modified ${getModifiedDate(file)}`;
const getTitle = (file) => execSync(`sed -n "s/^# \\(.*\\)/\\1/p" ${file}`).toString();
const getModifiedDate = (file) => fs.statSync(file).mtime.toLocaleDateString();

const createTOC = (fileGroups) => {
    const header = fs.readFileSync('./readme.header.md');
    const footer = fs.readFileSync('./readme.footer.md');
    const TOC = Object.keys(fileGroups).map(renderGroup).join('\n');
    return `${header}\n${TOC}\n${footer}`
}

fs.writeFileSync('./readme.md', createTOC(fileGroups))
