import java.io.File
import java.util.*
import javax.sound.midi.MidiEvent
import javax.sound.midi.MidiSystem
import javax.sound.midi.ShortMessage
import kotlin.collections.ArrayList
import kotlin.collections.HashMap
import kotlin.experimental.and
import kotlin.math.pow
import java.io.IOException
import java.io.FileWriter

fun main(args: Array<String>) {

    val fileName = "${args[0].subSequence(0, args[0].indexOf('.'))}.txt"

    createFile(fileName)
    writeNotes(args[0], fileName)
    //frequency()

    //notas(args[0])
}

private fun createFile(name: String) {

    try {
        val file = File(name)

        if (file.createNewFile()) {
            println("File created: " + file.name)
        } else {
            println("File already exists.")
        }

    } catch (e: IOException) {
        println("An error occurred.")
        e.printStackTrace()
    }
}

private fun frequency() {

    for (noteNumber in 0..127) {
        val frequency = 440 * 2.0.pow((noteNumber - 69) / 12.0)
        val frequencyInt = (1193180 / frequency).toInt()
        var frequencyHex = "0000" + Integer.toHexString(frequencyInt)
        frequencyHex = frequencyHex.substring(frequencyHex.length - 4, frequencyHex.length)
        if (noteNumber % 12 == 0) {
            print("\r\n\tDB  ")
        }
        frequencyHex = frequencyHex.uppercase(Locale.getDefault())
        frequencyHex = "${frequencyHex.subSequence(0, 2).padStart(3, '0')}h, " +
                "${frequencyHex.subSequence(2, 4).padStart(3, '0')}h"
        print(frequencyHex + if (noteNumber % 12 != 11) ", " else "")
    }
}

private fun writeNotes(midiFile: String, name: String) {
    val synthesizer = MidiSystem.getSynthesizer()
    synthesizer.open()
    val midiChannel = synthesizer.channels[0]
    val sequence = MidiSystem.getSequence(File(midiFile))

    println("Resolution: ${sequence.resolution}")
    println("Test: ${sequence.tickLength}")
    println("Tracks: ${sequence.tracks.size}")

    for (i in sequence.tracks.indices){
        println("Track $i: ${sequence.tracks[i].size()}")
    }

    val events = HashMap<Long, MutableList<MidiEvent?>>()

    for (t in 1 until 2) { //sequence.tracks.size
        val track = sequence.tracks[t]
        println(t)
        for (i in 0 until track.size()) {
            val me = track[i]
            val tick = me.tick
            var list: MutableList<MidiEvent?>? = events[tick]
            if (list == null) {
                list = ArrayList()
                events[tick] = list
            }
            list.add(me)
        }
    }

    val notes = ArrayList<Int>()

    var tick = 0L
    while (tick <= sequence.tickLength) {
        val list: MutableList<MidiEvent?>? = events[tick]
        if (list != null) {
            for (me in list) {
                val midiMessage = me?.message
                if (midiMessage != null) {
                    when (midiMessage.status and ShortMessage.NOTE_ON) {
                        ShortMessage.NOTE_ON -> {
                            val note = (midiMessage.message[1] and 0xff.toByte()).toInt()
                            val velocity = (midiMessage.message[2] and 0xff.toByte()).toInt()
                            midiChannel.noteOn(note, velocity)
                            //println("tick: $tick note_on: $note")
                            notes.add(note)
                        }
                        ShortMessage.NOTE_OFF -> {
                            val note2 = (midiMessage.message[1] and 0xff.toByte()).toInt()
                            //int velocity2 = (int) (midiMessage.getMessage()[2] & d0xff);
                            midiChannel.noteOff(note2)
                            //println("tick: $tick note_off: $note2")
                            notes.add(254)
                        }
                    }
                }
            }
        } else {
            // ignore
            notes.add(255)
        }
        tick += 8
    }

    println("Size: ${notes.size}")

    try {
        val fileWriter = FileWriter(name)

        for (i in 0 until notes.size) {
            val noteInt = notes[i]
            var noteStr = "00${Integer.toHexString(noteInt)}"
            noteStr = noteStr.substring(noteStr.length - 2, noteStr.length).uppercase(Locale.getDefault())

            fileWriter.write("${noteStr}${if (i % 16 == 15) "" else ""}")
        }

        fileWriter.close()
        println("Successfully wrote to the file.")

    } catch (e: IOException) {
        println("An error occurred.")
        e.printStackTrace()
    }
}
