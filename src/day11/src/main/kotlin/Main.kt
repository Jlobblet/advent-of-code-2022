import Monkey.Companion.toMonkey
import Monkeys.Companion.toMonkeys
import java.io.File
import java.math.BigInteger
import java.util.*
import kotlin.collections.ArrayDeque
import kotlin.collections.ArrayList
import kotlin.collections.HashMap
import kotlin.collections.List
import kotlin.collections.Map
import kotlin.collections.MutableList
import kotlin.collections.component1
import kotlin.collections.component2
import kotlin.collections.getOrPut
import kotlin.collections.isNotEmpty
import kotlin.collections.iterator
import kotlin.collections.last
import kotlin.collections.map
import kotlin.collections.mapValues
import kotlin.collections.reduce
import kotlin.collections.set
import kotlin.collections.sortedDescending
import kotlin.collections.take
import kotlin.collections.toList

class Operation(source: String) {
    private val lOperand: BigInteger?
    private val rOperand: BigInteger?
    private val operator: (BigInteger, BigInteger) -> BigInteger

    init {
        val s = source.split("=").last().trim().split(" ")
        this.lOperand = s[0].toBigIntegerOrNull()
        this.rOperand = s[2].toBigIntegerOrNull()

        this.operator = when (s[1]) {
            "*" -> ::mul
            "+" -> ::add
            else -> throw IllegalArgumentException("I'm throwing in a constructor lol")
        }
    }

    private fun mul(l: BigInteger, r: BigInteger): BigInteger {
        return l * r
    }

    private fun add(l: BigInteger, r: BigInteger): BigInteger {
        return l + r
    }

    fun apply(n: BigInteger): BigInteger {
        return operator(lOperand ?: n, rOperand ?: n)
    }
}

data class Monkey(
    val items: ArrayDeque<BigInteger>,
    private val operation: Operation,
    val test: BigInteger,
    private val trueTarget: Int,
    private val falseTarget: Int
) : Cloneable {
    var inspectCount: BigInteger = BigInteger.ZERO
    var mod: Optional<BigInteger> = Optional.empty()

    private fun inspect(item: BigInteger): Pair<BigInteger, Int> {
        inspectCount++
        var newValue = this.operation.apply(item)
        if (mod.isPresent) {
            newValue %= mod.get()
        } else {
            newValue /= BigInteger.valueOf(3)
        }

        val target = if (newValue % test == BigInteger.ZERO) {
            trueTarget
        } else {
            falseTarget
        }
        return Pair(newValue, target)
    }

    fun turn(): Map<Int, List<BigInteger>> {
        val moves = HashMap<Int, MutableList<BigInteger>>()
        while (items.isNotEmpty()) {
            val (item, target) = inspect(items.removeFirst())
            val targetList = moves.getOrPut(target) { ArrayList() }
            targetList.add(item)
        }
        return moves
    }

    public override fun clone(): Monkey = Monkey(ArrayDeque(items), operation, test, trueTarget, falseTarget)

    companion object {
        fun String.toMonkey(): Monkey {
            val lines = this.trim().lines().map { it.trim().split(": ")[1] }.toList()
            val items = ArrayDeque(lines[0].split(",").map { it.trim().toBigInteger() })
            val operation = Operation(lines[1])
            val test = lastToInt(lines[2]).toBigInteger()
            val trueTarget = lastToInt(lines[3])
            val falseTarget = lastToInt(lines[4])

            return Monkey(items, operation, test, trueTarget, falseTarget)
        }

        private fun lastToInt(s: String) = s.split(" ").last().toInt()
    }
}

data class Monkeys(private val monkeys: Map<Int, Monkey>) : Cloneable {
    private fun round() {
        for ((_, monkey) in monkeys) {
            val moves = monkey.turn()
            for ((target, items) in moves) {
                monkeys[target]!!.items.addAll(items)
            }
        }
    }

    fun keepAway(n: Int): BigInteger {
        repeat(n) {
            round()
        }
        return monkeys.map { it.value.inspectCount }.sortedDescending().take(2).reduce { acc, i -> acc * i }
    }

    fun part2Initialise() {
        val mod = monkeys.map { it.value.test }.reduce { acc, i -> acc * i }
        for ((_, monkey) in monkeys) {
            monkey.mod = Optional.of(mod)
        }
    }

    public override fun clone(): Monkeys = Monkeys(monkeys.mapValues { it.value.clone() })

    companion object {
        fun String.toMonkeys(): Monkeys {
            val map = HashMap<Int, Monkey>()
            for (m in this.split("\n\n")) {
                val lines = m.split("\n", limit = 2)
                val index = lines[0].trimEnd(':').split(" ").last().toInt()
                val monkey = lines[1].toMonkey()
                map[index] = monkey
            }
            return Monkeys(map)
        }
    }
}

fun main() {
    val monkeys = File(System.getenv("INPUT")).readText().toMonkeys()
    println(monkeys.clone().keepAway(20))
    monkeys.part2Initialise()
    print(monkeys.keepAway(10_000))
}
