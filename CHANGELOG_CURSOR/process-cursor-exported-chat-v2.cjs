#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

/**
 * Wrap all Cursor sections in a markdown file with <details> tags.
 * 
 * @param {string} inputFile - Path to the input markdown file
 * @param {string} outputFile - Path to the output file. If null, will create a dated filename.
 */
function wrapCursorSections(inputFile, outputFile = null) {
    try {
        // Read the input file
        const content = fs.readFileSync(inputFile, 'utf8');
        
        // Pattern to match **Cursor** followed by content until next **User** or end of file
        const cursorPattern = /(\*\*Cursor\*\*.*?)(?=\n\n\*\*User\*\*|$)/gs;
        
        // Replace all Cursor sections
        const modifiedContent = content.replace(cursorPattern, (match, cursorContent) => {
            return `<details>\n<summary>Cursor</summary>\n\n${cursorContent}\n</details>`;
        });
        
        // Determine output file with date prefix
        if (outputFile === null) {
            const date = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format
            const inputFileName = path.basename(inputFile);
            const inputDir = path.dirname(inputFile);
            outputFile = path.join(inputDir, `${date}_${inputFileName}`);
        }
        
        // Write the result
        fs.writeFileSync(outputFile, modifiedContent, 'utf8');
        
        // Remove the original file
        fs.unlinkSync(inputFile);
        
        console.log("Cursor sections have been wrapped with <details> tags!");
        console.log(`Original file removed: ${inputFile}`);
        console.log(`Output saved to: ${outputFile}`);
        
    } catch (error) {
        if (error.code === 'ENOENT') {
            throw new Error(`File '${inputFile}' not found.`);
        }
        throw error;
    }
}


/**
 * Removes all Cursor sections in a markdown file, leaving only the User sections.
 * 
 * @param {string} inputFile - Path to the input markdown file
 * @param {string} outputFile - Path to the output file. If null, will create a dated filename.
 */
function removeCursorSections(inputFile, outputFile = null) {
    try {
        // Read the input file
        const content = fs.readFileSync(inputFile, 'utf8');
        
        // Pattern to match **Cursor** followed by content until next **User** or end of file
        const cursorPattern = /\*\*Cursor\*\*.*?(?=\n\n\*\*User\*\*|$)/gs;
        
        // Remove all Cursor sections, keeping only User sections
        const modifiedContent = content.replace(cursorPattern, '');
        
        // Clean up any double newlines that might result from removal
        const cleanedContent = modifiedContent.replace(/\n\n\n+/g, '\n\n');
        
        // Determine output file with date prefix
        if (outputFile === null) {
            const date = new Date().toISOString().split('T')[0]; // YYYY-MM-DD format
            const inputFileName = path.basename(inputFile);
            const inputDir = path.dirname(inputFile);
            outputFile = path.join(inputDir, `${date}_${inputFileName}`);
        }
        
        // Write the result
        fs.writeFileSync(outputFile, cleanedContent, 'utf8');
        
        // Remove the original file
        fs.unlinkSync(inputFile);
        
        console.log("Cursor sections have been removed, keeping only User sections!");
        console.log(`Original file removed: ${inputFile}`);
        console.log(`Output saved to: ${outputFile}`);
        
    } catch (error) {
        if (error.code === 'ENOENT') {
            throw new Error(`File '${inputFile}' not found.`);
        }
        throw error;
    }
}

/**
 * Main function to handle command line arguments.
 * 
 * Asks the user which operation to perform: 
 * 1. Remove Cursor sections
 * 2. Wrap Cursor sections
 */
function main() {
    const args = process.argv.slice(2);
    
    if (args.length < 1) {
        console.log("Usage: node process-cursor-exported-chat.js <input_file> [output_file]");
        console.log("If output_file is not specified, a new file will be created with date prefix and the original file will be removed.");
        process.exit(1);
    }
    
    const inputFile = args[0];
    const outputFile = args.length > 1 ? args[1] : null;
    
    // Create readline interface
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });
    
    // Ask user which operation to perform
    console.log("Choose an operation:");
    console.log("1. Remove Cursor sections (keep only User sections)");
    console.log("2. Wrap Cursor sections with <details> tags");
    
    rl.question("Enter your choice (1 or 2): ", (choice) => {
        rl.close();
        
        try {
            if (choice === '1') {
                removeCursorSections(inputFile, outputFile);
            } else if (choice === '2') {
                wrapCursorSections(inputFile, outputFile);
            } else {
                console.error("Invalid choice. Please choose 1 or 2.");
                process.exit(1);
            }
        } catch (error) {
            console.error(`Error: ${error.message}`);
            process.exit(1);
        }
    });
}

// Run the main function if this script is executed directly
if (require.main === module) {
    main();
}

module.exports = { wrapCursorSections, removeCursorSections };
