const { Midi } = require("@tonejs/midi");
const fs = require("fs");

const midiData = fs.readFileSync("test.mid");
const midi = new Midi(midiData);

track = midi.tracks[0];
track_length = track.duration;
notes = track.notes;

function generateNoteHTML(note) {
  let html = `<div style="background-color: hsl(0, 0%, ${
    (frequencyToGreyScale(getFrequency(note.midi)),
    frequencyToGreyScale(getFrequency(note.midi)),
    frequencyToGreyScale(getFrequency(note.midi)))
  }%); width: ${
    note.durationTicks * 100
  }px; height: 100%; display: inline-block; margin: 0; padding: 0;"></div>`;

  return html;
}

/**
 * Used to simulate stacatto notes by adding a div with a width of note_length * 100px
 * @param {number} note_length
 * @returns {string} html
 */
function generateNoteSeparationHTML(note_length) {
  let html = `<div style="width: ${
    note_length * 100
  }px; height: 100%; display: inline-block; margin: 0; padding: 0;"></div>`;

  return html;
}

const styles = `<style>body {margin: 0; padding: 0; overflow-x: scroll; display: flex;}</style>`;

function generateTrackHTML(track) {
  let html = "";
  let track_duration = track.durationTicks;
  let notes = track.notes;

  const note_separator = 300;
  const max_page_size = 3000;

  let previous_empty_time = 0;

  let flipped_page = false;

  for (let i = 0; i < track_duration; i++) {
    // Get all the notes that are played at the current time
    let notes_at_time = notes.filter((note) => note.ticks == i);
    console.log(track_duration, i);

    // If there are no notes played at the current time, add a div with a width of 100px
    if (notes_at_time.length == 0) {
      if (!previous_empty_time) {
        previous_empty_time = i;
      }
      continue;
    }

    // If there are notes played at the current time, add a div for each note
    else {
      // If the previous time had no notes, add a div with a width of 100px
      if (previous_empty_time) {
        html += generateNoteSeparationHTML(i - previous_empty_time);
        html += generateNoteSeparationHTML(note_separator);
        previous_empty_time = null;
      }

      notes_at_time.forEach((note) => {
        html += generateNoteHTML(note);
        html += generateNoteSeparationHTML(note_separator);
      });

      i += notes_at_time[0].durationTicks;
      if (i > max_page_size && !flipped_page) {
        let trackHtml = styles + html;
        fs.writeFileSync("test1.html", trackHtml);
        html = "";
        flipped_page = true;
      }
    }

    if ((i == track_duration - 1) & previous_empty_time) {
      html += generateNoteSeparationHTML(i - previous_empty_time);
    }
  }

  fs.writeFileSync("test2.html", styles + html);
}

function getFrequency(note) {
  return 440 * Math.pow(2, (note - 69) / 12);
}

function frequencyToGreyScale(
  frequency,
  maxFrequency = 450,
  minFrequency = 260
) {
  greyscale = Math.round(
    ((frequency - minFrequency) / (maxFrequency - minFrequency)) * 100
  );
  return greyscale;
}

// Display all the frequencies of the notes in the first track
midi.tracks[0].notes.forEach((note) => {
  console.log(getFrequency(note.midi), 550, 260);
});

generateTrackHTML(midi.tracks[0]);
