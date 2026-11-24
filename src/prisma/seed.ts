import { prisma } from "@/lib/prisma";
import { BusinessType, BusinessCategory } from "@/app/generated/prisma/client";

const businesses = [
  {
    name: "Demo order",
    type: BusinessType.orders,          // ← fix if red (see below)
    category: BusinessCategory.cosmetics,        // ← fix if red, or use null
    notes: "Seeded business",
  },
  {
    name: "Demo Shop",
    type: BusinessType.shop,                // ← fix if red
    category: null,
    notes: null,
  },
];

async function main() {
  for (const b of businesses) {
    const existing = await prisma.business.findFirst({ where: { name: b.name } });
    if (existing) {
      console.log(`skip: ${b.name} (already exists, id ${existing.id})`);
      continue;
    }
    const created = await prisma.business.create({ data: b });
    console.log(`created: ${created.name} (id ${created.id})`);
  }
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });